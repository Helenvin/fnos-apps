<script setup>
// ============ SQMusic 发现页（全网音乐聚合门户 v4） ============
// 多源缝合：酷狗（榜单/歌手/专辑全链路浏览）+ QQ（歌单广场/详情）+ sqmusic 后端（全源搜索/播放直链/下载）
// 播放：行内 ▶ 按钮 → 后端 getDownloadUrl 解析直链 → 底部全局播放条；qq 源跨源换票兜底
// 下载：行内 ⬇ 按钮 → 搜索换票 → downloadSong；每行均可播放/下载
import { ref, computed, nextTick } from "vue";
import axios from "axios";
import {
    musicSearch,
    musicDownload,
    getMusicUrl,
    parserUrlInfo,
    parserUrlSongs
} from "../utils/api.js";

// ---------- 代理 ----------
const qq = axios.create({ baseURL: "/qq", timeout: 25000 });
const qqGet = async (path, params) => {
    const res = await qq.get(path, { params });
    return typeof res.data === "string" ? JSON.parse(res.data.replace(/^\w+\(|\)$/g, "")) : res.data;
};
const kg = axios.create({ baseURL: "/kg", timeout: 25000 });
const kgGet = async (path) => {
    const res = await kg.get(path);
    return res.data;
};

// ---------- 视图状态 ----------
const view = ref("home"); // home | ranks | singers | singerDetail | albumDetail | plaza | dissDetail | search
const backStack = ref([]); // [{view, restore}]
const goBack = () => {
    const b = backStack.value.pop();
    if (b && b.restore) b.restore();
    else view.value = "home";
};
const pushView = (v, restore) => {
    backStack.value.push({ view: view.value, restore });
    view.value = v;
};
const navHome = () => { backStack.value = []; view.value = "home"; };

// ---------- 统一歌曲行 ----------
const fmtListen = (n) => {
    const v = Number(n) || 0;
    return v >= 100000000 ? (v / 100000000).toFixed(1) + "亿" : v >= 10000 ? Math.round(v / 10000) + "万" : String(v);
};
const fmtDur = (s) => {
    const t = Number(s) || 0;
    if (!t) return "";
    return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0");
};
const kgImg = (tpl, size) => (tpl || "").replace("{size}", size || 240);

// 行：{idx, id, name, singer, album, duration, pic, brTypes, raw, source}
const toRows = (list, source) => list.map((m, i) => {
    if (source === "kg") {
        const fname = m.filename || "";
        const sep = fname.indexOf(" - ");
        const name = sep > 0 ? fname.slice(sep + 3) : fname;
        const singer = sep > 0 ? fname.slice(0, sep) : (m.singername || "");
        return {
            idx: i + 1, id: m.album_audio_id || m.hash || "", name, singer,
            album: m.album_name || "", duration: m.duration || 0, pic: "",
            brTypes: [], raw: null, source: "kg", hash: m.hash || ""
        };
    }
    if (source === "qq") {
        const d = m.data || {};
        return {
            idx: i + 1, id: m.mid || d.songmid || "", name: m.name || d.songname || "",
            singer: (m.singer || d.singer || []).map(x => x.name).join("/"),
            album: m.album || d.albumname || "", duration: m.interval || d.interval || 0,
            pic: d.albummid ? "https://y.gtimg.cn/music/photo_new/T002R300x300M000" + d.albummid + ".jpg" : "",
            brTypes: [], raw: null, source: "qq"
        };
    }
    // 后端原生 Music
    const pic = m.musicImage || m.pic || "";
    return {
        idx: i + 1, id: m.id || "", name: m.musicName || m.name || "",
        singer: Array.isArray(m.musicArtists) ? m.musicArtists.join("/") : (m.singer || ""),
        album: m.musicAlbum || "", duration: m.musicDuration || 0,
        pic, brTypes: m.bits || m.brTypes || [], raw: m, source: m.plugName || ""
    };
});

// ---------- 换票（列表行 → 后端原生 Music） ----------
const SOURCE_LABEL = { kg: "酷狗", qq: "QQ音乐", kw: "酷我", mg: "咪咕", netease: "网易云", qqvip: "QQ VIP", tidal: "TIDAL" };
const swapTicket = async (song, preferPlug) => {
    const kw = (song.name + " " + song.singer).trim();
    const order = [];
    if (preferPlug && preferPlug !== "qq") order.push(preferPlug);
    for (const p of ["kg", "netease", "kw"]) if (!order.includes(p)) order.push(p);
    for (const plug of order) {
        try {
            const res = await musicSearch(plug, "music", kw, 5, 1);
            const records = (res.data && res.data.code === 200 && res.data.data && res.data.data.records) || [];
            if (records.length && records[0].id) return { music: JSON.parse(JSON.stringify(records[0])), plug };
        } catch (e) { /* 下一个源 */ }
    }
    throw new Error("全源未搜索到「" + kw + "」");
};

// ---------- 播放 ----------
const audio = ref(null);
const playing = ref(false);
const curRow = ref(null);      // 正在播放的统一行
const playUrl = ref("");
const playLoading = ref(false);
const playQueue = ref([]);     // 待播列表
const playError = ref("");

const BR_ENUM = { kg: "KG_MP3_128", kw: "KW_MP3_128", mg: "MG_MP3_128", netease: "NETEASE_MP3_128", qqvip: "QQVIP_MP3_128", tidal: "TIDAL_M4A_320" };

const resolveUrl = async (raw, plugHint) => {
    // raw: 后端原生 Music；返回 {url, plug}
    const plug = raw.plugName || plugHint;
    const candidates = [];
    if (plug && BR_ENUM[plug]) candidates.push({ music: raw, br: BR_ENUM[plug] });
    for (const p of ["kg", "netease", "kw"]) {
        if (p !== plug) candidates.push({ music: raw, br: BR_ENUM[p] });
    }
    for (const c of candidates) {
        try {
            const res = await getMusicUrl(JSON.parse(JSON.stringify(c.music)), c.br);
            if (res.data && res.data.code === 200 && res.data.data && res.data.data.url) {
                return { url: res.data.data.url, plug: plugHint };
            }
        } catch (e) { /* 尝试下一个 */ }
    }
    return null;
};

const playOne = async (song) => {
    if (playLoading.value) return;
    playLoading.value = true;
    playError.value = "";
    curRow.value = song;
    try {
        let music = song.raw;
        let plug = song.source;
        if (!music || !music.id || !music.plugName) {
            const t = await swapTicket(song, song.source);
            music = t.music; plug = t.plug;
        }
        let r = await resolveUrl(music, plug);
        if (!r) { // 跨源换票兜底
            const t = await swapTicket(song, "kg");
            r = await resolveUrl(t.music, t.plug);
        }
        if (!r) throw new Error("无法解析播放链接");
        playUrl.value = r.url;
        await nextTick();
        if (audio.value) { audio.value.src = r.url; audio.value.play().catch(() => {}); }
        playing.value = true;
    } catch (e) {
        playError.value = "播放失败：" + (e.message || e);
        window.$message.warning(playError.value);
        playing.value = false;
    }
    playLoading.value = false;
};

const togglePlay = () => {
    if (!audio.value || !playUrl.value) return;
    if (playing.value) { audio.value.pause(); playing.value = false; }
    else { audio.value.play().catch(() => {}); playing.value = true; }
};

const playNext = () => {
    if (!playQueue.value.length) { playing.value = false; return; }
    const next = playQueue.value.shift();
    playOne(next);
};

const playAll = async (songs, listName) => {
    if (!songs.length) return;
    playQueue.value = songs.slice(1);
    window.$message.info("开始播放《" + listName + "》");
    await playOne(songs[0]);
};

// ---------- 下载（换票链路） ----------
const dlRunning = ref(false);
const dlStop = ref(false);
const dlDone = ref(0);
const dlTotal = ref(0);
const dlFail = ref(0);

const pickBr = (raw) => {
    const bts = raw && (raw.brTypes || raw.bits) || [];
    return bts.length ? bts[0] : null;
};

const downloadOne = async (song) => {
    let music = song.raw;
    let plug = song.source;
    if (!music || !music.id || !music.plugName) {
        const t = await swapTicket(song, song.source);
        music = t.music; plug = t.plug;
    }
    const br = pickBr(music);
    if (!br) throw new Error("无可下载码率");
    const dres = await musicDownload(music, br);
    if (!dres.data || dres.data.code !== 200) throw new Error(dres.data?.msg || "下载失败");
};

const dlBusy = ref({});
const busyKey = (v, idx) => v + "#" + idx;
const downloadBtn = async (song, viewName = "cur") => {
    const key = busyKey(viewName, song.idx);
    if (dlBusy.value[key]) return;
    dlBusy.value = { ...dlBusy.value, [key]: true };
    try {
        await downloadOne(song);
        window.$message.success("已加入下载：" + song.name);
    } catch (e) {
        window.$message.error("下载失败：" + (e.message || e));
    }
    const next = { ...dlBusy.value };
    delete next[key];
    dlBusy.value = next;
};

const downloadAll = async (songs, listName) => {
    if (dlRunning.value || !songs.length) return;
    dlRunning.value = true;
    dlStop.value = false;
    dlFail.value = 0;
    dlTotal.value = songs.length;
    dlDone.value = 0;
    window.$message.info("开始下载《" + listName + "》共 " + songs.length + " 首");
    const queue = songs.map(s => s);
    const worker = async () => {
        while (queue.length) {
            if (dlStop.value) return;
            const s = queue.shift();
            try { await downloadOne(s); } catch (e) { dlFail.value++; }
            dlDone.value++;
        }
    };
    worker();
};

// ================= 酷狗：榜单 =================
const KG_RANK_GROUPS = [
    { label: "精选", items: [
        { id: 8888, name: "TOP500" }, { id: 6666, name: "飙升榜" }, { id: 74534, name: "新歌榜" },
        { id: 82831, name: "网络热歌榜" }, { id: 85432, name: "百万收藏榜" }, { id: 52144, name: "短视频热歌榜" },
        { id: 24971, name: "DJ热歌榜" }, { id: 35811, name: "会员热歌榜" } ] },
    { label: "风格", items: [
        { id: 59896, name: "摇滚榜" }, { id: 33160, name: "电音榜" }, { id: 51341, name: "民谣榜" },
        { id: 44412, name: "说唱先锋榜" }, { id: 59895, name: "R&B榜" }, { id: 59897, name: "爵士榜" },
        { id: 59898, name: "乡村音乐榜" }, { id: 59899, name: "古典榜" }, { id: 59900, name: "纯音乐榜" },
        { id: 80025, name: "国乐榜" }, { id: 85897, name: "国潮音乐榜" } ] },
    { label: "地区 · 语言", items: [
        { id: 31308, name: "内地榜" }, { id: 33165, name: "粤语金曲榜" }, { id: 31313, name: "香港地区榜" },
        { id: 54848, name: "台湾地区榜" }, { id: 31310, name: "欧美榜" }, { id: 33166, name: "欧美金曲榜" },
        { id: 31311, name: "韩国榜" }, { id: 38623, name: "韩国Melon榜" }, { id: 31312, name: "日本榜" },
        { id: 4673, name: "日本公信榜" }, { id: 60170, name: "闽南语榜" }, { id: 36107, name: "小语种热歌榜" },
        { id: 4681, name: "美国BillBoard榜" }, { id: 4680, name: "英国单曲榜" } ] },
    { label: "年代 · 场景", items: [
        { id: 49225, name: "80后热歌榜" }, { id: 49223, name: "90后热歌榜" }, { id: 49224, name: "00后热歌榜" },
        { id: 33163, name: "影视金曲榜" }, { id: 33162, name: "ACG新歌榜" }, { id: 46910, name: "综艺新歌榜" },
        { id: 65234, name: "儿歌榜" }, { id: 30972, name: "音乐人原创榜" } ] }
];
const kgAllRanks = ref([]);          // [{id,name,imgurl}] 榜单页网格
const kgRankImg = ref({});
const kgRankLoading = ref(false);
const loadKgRanks = async () => {
    if (kgAllRanks.value.length) return;
    kgRankLoading.value = true;
    try {
        const j = await kgGet("/rank/list&json=true");
        kgAllRanks.value = ((j.rank || {}).list || []).map(r => ({ id: r.rankid, name: r.rankname, pic: r.imgurl || "" }));
    } catch (e) {
        window.$message.error("榜单列表加载失败：" + (e.message || e));
    }
    kgRankLoading.value = false;
};

// 榜单歌曲详情（复用 detail 状态）
const curRows = ref([]);
const curTitle = ref("");
const curSub = ref("");
const curLoading = ref(false);
const rowsView = ref("");  // 当前表属于哪个视图（busyKey 用）
const curPage = ref(1);
const curRankId = ref(null);

const openRank = async (rk, jumpView) => {
    if (jumpView) { pushView("ranks", null); view.value = jumpView; }
    curTitle.value = rk.name;
    curSub.value = "酷狗榜单 · 每页 30 首";
    curRows.value = [];
    rowsView.value = "rank" + rk.id;
    curLoading.value = true;
    try {
        const j = await kgGet("/rank/info/?rankid=" + rk.id + "&page=1&json=true");
        curRows.value = toRows((j.songs || {}).list || [], "kg");
        if (!curRows.value.length) window.$message.warning("该榜单暂无数据");
    } catch (e) {
        window.$message.error("榜单歌曲加载失败：" + (e.message || e));
    }
    curLoading.value = false;
};
const rankMore = async () => {
    if (curLoading.value) return;
    curPage.value += 1;
    curLoading.value = true;
    try {
        const j = await kgGet("/rank/info/?rankid=" + curRankId.value + "&page=" + curPage.value + "&json=true");
        const more = toRows((j.songs || {}).list || [], "kg");
        curRows.value = curRows.value.concat(more);
    } catch (e) { curPage.value -= 1; }
    curLoading.value = false;
};

// ================= 酷狗：歌手 =================
const KG_CLASSES = [
    { id: 1, label: "华语男" }, { id: 2, label: "华语女" }, { id: 3, label: "华语组合" },
    { id: 4, label: "欧美男" }, { id: 5, label: "欧美女" }, { id: 6, label: "欧美组合" },
    { id: 7, label: "日本男" }, { id: 8, label: "日本女" }, { id: 9, label: "日本组合" },
    { id: 10, label: "韩国男" }, { id: 11, label: "韩国女" }, { id: 12, label: "韩国组合" },
    { id: 13, label: "其他" }
];
const singerClass = ref(1);
const singerList = ref([]);
const singerPage = ref(1);
const singerLoading = ref(false);
const singerHasMore = ref(true);

const loadSingers = async (reset) => {
    if (singerLoading.value) return;
    if (reset) { singerPage.value = 1; singerList.value = []; singerHasMore.value = true; }
    singerLoading.value = true;
    try {
        const j = await kgGet("/api/v3/singer/list?classid=" + singerClass.value + "&page=" + singerPage.value + "&pagesize=36&format=json");
        const info = (j.data || {}).info || [];
        singerList.value = reset ? info : singerList.value.concat(info);
        singerHasMore.value = info.length >= 36;
        singerPage.value += 1;
    } catch (e) {
        window.$message.error("歌手加载失败：" + (e.message || e));
    }
    singerLoading.value = false;
};
const switchSingerClass = (id) => { singerClass.value = id; loadSingers(true); };

const curSinger = ref(null);
const singerTab = ref("songs"); // songs | albums
const singerSongs = ref([]);
const singerAlbums = ref([]);
const singerIntro = ref("");
const singerDetailLoading = ref(false);

const openSinger = async (s, fromView) => {
    const restore = () => { /* 返回时保留列表 */ };
    pushView(fromView || "singers", restore);
    view.value = "singerDetail";
    curSinger.value = { id: s.singerid, name: s.singername, pic: kgImg(s.imgurl, 240) };
    singerTab.value = "songs";
    singerSongs.value = [];
    singerAlbums.value = [];
    singerIntro.value = "";
    singerDetailLoading.value = true;
    try {
        const j = await kgGet("/api/v3/singer/info?singerid=" + s.singerid + "&format=json");
        singerIntro.value = ((j.data || {}).intro || "").slice(0, 160);
    } catch (e) { /* 简介可选 */ }
    try {
        const js = await kgGet("/api/v3/singer/song?singerid=" + s.singerid + "&page=1&pagesize=50&format=json");
        singerSongs.value = toRows((js.data || {}).info || [], "kg");
    } catch (e) {
        window.$message.error("歌手歌曲加载失败：" + (e.message || e));
    }
    singerDetailLoading.value = false;
};

const loadSingerAlbums = async () => {
    if (singerAlbums.value.length) { singerTab.value = "albums"; return; }
    singerDetailLoading.value = true;
    try {
        const j = await kgGet("/api/v3/singer/album?singerid=" + curSinger.value.id + "&page=1&pagesize=60&format=json");
        singerAlbums.value = ((j.data || {}).info || []).map(a => ({
            albumid: a.albumid, name: a.albumname, pic: kgImg(a.imgurl, 240),
            pub: (a.publishtime || "").slice(0, 10), singername: a.singername || ""
        }));
    } catch (e) {
        window.$message.error("专辑加载失败：" + (e.message || e));
    }
    singerDetailLoading.value = false;
    singerTab.value = "albums";
};

// ================= 酷狗：专辑详情 =================
const curAlbum = ref(null);
const albumLoading = ref(false);
const openAlbum = async (a) => {
    pushView("singerDetail", null);
    view.value = "albumDetail";
    curAlbum.value = a;
    curTitle.value = a.name;
    curSub.value = (a.pub ? a.pub + " · " : "") + "酷狗专辑";
    curRows.value = [];
    rowsView.value = "album" + a.albumid;
    albumLoading.value = true;
    try {
        const j = await kgGet("/api/v3/album/song?albumid=" + a.albumid + "&page=1&pagesize=100&format=json");
        curRows.value = toRows((j.data || {}).info || [], "kg");
    } catch (e) {
        window.$message.error("专辑歌曲加载失败：" + (e.message || e));
    }
    albumLoading.value = false;
};

// ================= QQ 歌单广场 =================
const QQ_PLAZA_CATS = [
    { label: "热门", id: "10000000" }, { label: "华语", id: "168" }, { label: "流行", id: "118" },
    { label: "摇滚", id: "149" }, { label: "民谣", id: "133" }, { label: "电子", id: "109" },
    { label: "说唱", id: "188" }, { label: "粤语", id: "197" }, { label: "日韩", id: "148" },
    { label: "欧美", id: "141" }, { label: "轻音乐", id: "131" }, { label: "影视原声", id: "104" },
    { label: "ACG", id: "21" }, { label: "爵士", id: "92" }, { label: "古典", id: "136" }
];
const plazaCat = ref("10000000");
const plazaList = ref([]);
const plazaLoading = ref(false);
const loadPlaza = async () => {
    plazaLoading.value = true;
    try {
        const j = await qqGet("/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg", {
            picmid: 1, rnd: Math.random(), g_tk: 732560959, loginUin: 0, hostUin: 0,
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0,
            platform: "yqq.json", needNewCode: 0,
            categoryId: plazaCat.value, sortId: 5, sin: 0, ein: 29
        });
        plazaList.value = (((j.data || {}).list) || []).map(d => ({
            id: String(d.dissid || ""), name: d.dissname || "未命名歌单",
            pic: d.imgurl || d.imgv30 || d.picurl || "", listen: d.listennum || 0
        }));
        if (!plazaList.value.length) window.$message.warning("该分类暂无数据，换一个分类试试");
    } catch (e) {
        window.$message.error("歌单广场加载失败：" + (e.message || e));
    }
    plazaLoading.value = false;
};
const switchPlaza = (id) => { plazaCat.value = id; loadPlaza(); };

// ================= QQ 歌单详情 =================
const curDiss = ref(null);
const dissLoading = ref(false);
const dissUrl = (id) => "https://y.qq.com/n/ryqq/playlist/" + id;
const openDiss = async (d) => {
    pushView("plaza", null);
    view.value = "dissDetail";
    curTitle.value = d.name;
    curSub.value = "QQ音乐歌单 · 播放 " + fmtListen(d.listen);
    curDiss.value = d;
    curRows.value = [];
    rowsView.value = "diss" + d.id;
    dissLoading.value = true;
    try {
        const url = dissUrl(d.id);
        const [metaRes, songsRes] = await Promise.allSettled([parserUrlInfo(url), parserUrlSongs(url)]);
        if (metaRes.status === "fulfilled" && metaRes.value.data && metaRes.value.data.code === 200) {
            const m = metaRes.value.data.data || {};
            curDiss.value = { ...d, cover: m.pic || m.musicImage || d.pic, desc: m.desc || m.introduce || "" };
        }
        if (songsRes.status === "fulfilled" && songsRes.value.data && songsRes.value.data.code === 200) {
            const musics = songsRes.value.data.data || [];
            curRows.value = toRows(musics, "backend");
            if (!curRows.value.length) window.$message.warning("解析到 0 首歌曲，请重试");
        } else {
            window.$message.error("歌单解析失败，请重试");
        }
    } catch (e) {
        window.$message.error("歌单解析失败：" + (e.message || e));
    }
    dissLoading.value = false;
};

// ================= 首页 =================
const homeRanks = [
    { id: 8888, name: "TOP500" }, { id: 6666, name: "飙升榜" }, { id: 59896, name: "摇滚榜" },
    { id: 33160, name: "电音榜" }, { id: 74534, name: "新歌榜" }, { id: 51341, name: "民谣榜" },
    { id: 44412, name: "说唱先锋榜" }, { id: 33165, name: "粤语金曲榜" }
];
const homeSingers = ref([]);
const homePlaza = ref([]);
const homeLoading = ref(false);
const loadHome = async () => {
    if (homeLoading.value || homeSingers.value.length) return;
    homeLoading.value = true;
    // 热门歌手（华语男前 18）
    try {
        const j = await kgGet("/api/v3/singer/list?classid=1&page=1&pagesize=18&format=json");
        homeSingers.value = ((j.data || {}).info || []).map(s => ({ singerid: s.singerid, singername: s.singername, imgurl: kgImg(s.imgurl, 150) }));
    } catch (e) { /* 可选 */ }
    // QQ 热门歌单前 10
    try {
        const j = await qqGet("/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg", {
            picmid: 1, rnd: Math.random(), g_tk: 732560959, loginUin: 0, hostUin: 0,
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0,
            platform: "yqq.json", needNewCode: 0,
            categoryId: "10000000", sortId: 5, sin: 0, ein: 9
        });
        homePlaza.value = (((j.data || {}).list) || []).map(d => ({
            id: String(d.dissid || ""), name: d.dissname || "", pic: d.imgurl || d.imgv30 || "", listen: d.listennum || 0
        }));
    } catch (e) { /* 可选 */ }
    homeLoading.value = false;
};

// ================= 搜索 =================
const searchPlug = ref("kg");
const searchKw = ref("");
const searchLoading = ref(false);
const searchInput = ref("");
const doSearch = async () => {
    const kw = (searchInput.value || "").trim();
    if (!kw) return;
    searchKw.value = kw;
    pushView(view.value, null);
    view.value = "search";
    curTitle.value = "搜索「" + kw + "」";
    curSub.value = "来源：" + (SOURCE_LABEL[searchPlug.value] || searchPlug.value);
    curRows.value = [];
    rowsView.value = "search";
    searchLoading.value = true;
    try {
        const res = await musicSearch(searchPlug.value, "music", kw, 30, 1);
        const records = (res.data && res.data.code === 200 && res.data.data && res.data.data.records) || [];
        curRows.value = toRows(records, "backend");
        if (!curRows.value.length) window.$message.warning("未搜索到结果");
    } catch (e) {
        window.$message.error("搜索失败：" + (e.message || e));
    }
    searchLoading.value = false;
};

// ================= 进入视图钩子 =================
const setView = (v) => {
    backStack.value = [];
    view.value = v;
    if (v === "ranks") loadKgRanks();
    if (v === "singers" && !singerList.value.length) loadSingers(true);
    if (v === "plaza" && !plazaList.value.length) loadPlaza();
    if (v === "home") loadHome();
};
loadHome();
</script>

<template>
<div class="discover">
    <!-- 顶部导航 -->
    <header class="hd">
        <div class="hd-inner">
            <div class="logo" @click="navHome">♫ 发现音乐</div>
            <nav class="nav">
                <div class="nav-item" :class="{ active: view === 'home' }" @click="setView('home')">首页</div>
                <div class="nav-item" :class="{ active: view === 'ranks' }" @click="setView('ranks')">排行榜</div>
                <div class="nav-item" :class="{ active: view === 'singers' || view === 'singerDetail' || view === 'albumDetail' }" @click="setView('singers')">歌手</div>
                <div class="nav-item" :class="{ active: view === 'plaza' || view === 'dissDetail' }" @click="setView('plaza')">歌单</div>
            </nav>
            <div class="search-box">
                <input v-model="searchInput" placeholder="搜索歌曲 / 歌手 / 专辑" @keyup.enter="doSearch" />
                <button class="s-btn" @click="doSearch">搜索</button>
            </div>
        </div>
    </header>

    <main class="bd">
        <!-- 返回条（详情视图） -->
        <div v-if="view === 'singerDetail' || view === 'albumDetail' || view === 'dissDetail' || view === 'search'" class="backbar" @click="goBack">
            ← 返回
        </div>

        <!-- ===== 首页 ===== -->
        <section v-if="view === 'home'" class="home">
            <div class="hero">
                <div class="hero-t">全网音乐聚合</div>
                <div class="hero-d">酷狗榜单 · 歌手专辑 · QQ 歌单 · 七源搜索 · 在线播放 · 一键下载入库</div>
            </div>
            <h3 class="sec-t">酷狗精选榜</h3>
            <div class="card-grid">
                <div v-for="rk in homeRanks" :key="rk.id" class="rank-card" @click="openRank(rk, 'ranks')">
                    <div class="rc-icon">♫</div>
                    <div class="rc-name">{{ rk.name }}</div>
                    <div class="rc-go">查看榜单 →</div>
                </div>
            </div>
            <h3 class="sec-t">热门歌手 <span class="sec-more" @click="setView('singers')">全部歌手 →</span></h3>
            <div class="singer-row">
                <div v-for="s in homeSingers" :key="s.singerid" class="singer-cell" @click="openSinger(s, 'home')">
                    <img class="sc-img" :src="s.imgurl" loading="lazy" />
                    <div class="sc-name">{{ s.singername }}</div>
                </div>
            </div>
            <h3 class="sec-t">QQ 精选歌单 <span class="sec-more" @click="setView('plaza')">全部歌单 →</span></h3>
            <div class="diss-grid">
                <div v-for="d in homePlaza" :key="d.id" class="diss-card" @click="openDiss(d)">
                    <img class="dc-img" :src="d.pic" loading="lazy" />
                    <div class="dc-name">{{ d.name }}</div>
                    <div class="dc-play">▶ {{ fmtListen(d.listen) }}</div>
                </div>
            </div>
        </section>

        <!-- ===== 排行榜 ===== -->
        <section v-if="view === 'ranks'" class="ranks-page">
            <aside class="rk-side">
                <div v-for="g in KG_RANK_GROUPS" :key="g.label" class="rk-group">
                    <div class="rk-glabel">{{ g.label }}</div>
                    <div v-for="rk in g.items" :key="rk.id" class="rk-item" :class="{ active: curTitle === rk.name }" @click="curRankId = rk.id; openRank(rk)">
                        {{ rk.name }}
                    </div>
                </div>
            </aside>
            <div class="rk-main">
                <!-- 歌曲表（详情复用区） -->
                <div class="tbl-head">
                    <div class="th-title">{{ curTitle || "选择左侧榜单" }}</div>
                    <div class="th-sub">{{ curSub }}</div>
                    <div v-if="curRows.length" class="th-ops">
                        <button class="op-btn play" @click="playAll(curRows, curTitle)">▶ 播放全部</button>
                        <button v-if="!dlRunning" class="op-btn" @click="downloadAll(curRows, curTitle)">⬇ 下载全部</button>
                        <button v-else class="op-btn stop" @click="dlStop = true">■ 停止 ({{ dlDone }}/{{ dlTotal }})</button>
                    </div>
                </div>
                <div v-if="curLoading" class="loading">加载中…</div>
                <div v-else class="song-table">
                    <div v-for="row in curRows" :key="rowsView + row.idx" class="song-row" :class="{ playing: curRow && curRow.idx === row.idx && rowsView === view }">
                        <div class="col-idx">{{ row.idx }}</div>
                        <div class="col-main">
                            <div class="r-name" :class="{ cur: curRow && curRow.idx === row.idx && rowsView === view }">{{ row.name }}</div>
                            <div class="r-sub">{{ row.singer }}<span v-if="row.album"> · {{ row.album }}</span></div>
                        </div>
                        <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                        <button class="icon-btn play" :disabled="playLoading && curRow && curRow.idx === row.idx" @click="playOne(row)">
                            {{ playLoading && curRow && curRow.idx === row.idx ? '…' : (curRow && curRow.idx === row.idx && playing ? '❚❚' : '▶') }}
                        </button>
                        <button class="icon-btn dl" :disabled="dlBusy[busyKey(rowsView, row.idx)]" @click="downloadBtn(row, rowsView)">
                            {{ dlBusy[busyKey(rowsView, row.idx)] ? '…' : '⬇' }}
                        </button>
                    </div>
                </div>
                <div v-if="view === 'ranks' && curRows.length && curRankId" class="more-area">
                    <button class="op-btn" @click="curPage = 1; rankMore()">加载更多</button>
                </div>
            </div>
        </section>

        <!-- ===== 歌手 ===== -->
        <section v-if="view === 'singers'" class="singers-page">
            <div class="chip-row">
                <div v-for="c in KG_CLASSES" :key="c.id" class="chip" :class="{ active: singerClass === c.id }" @click="switchSingerClass(c.id)">{{ c.label }}</div>
            </div>
            <div class="singer-grid">
                <div v-for="s in singerList" :key="s.singerid" class="singer-cell big" @click="openSinger(s, 'singers')">
                    <img class="sc-img" :src="kgImg(s.imgurl, 240)" loading="lazy" />
                    <div class="sc-name">{{ s.singername }}</div>
                </div>
            </div>
            <div class="more-area">
                <button v-if="singerHasMore" class="op-btn" :disabled="singerLoading" @click="loadSingers(false)">{{ singerLoading ? '加载中…' : '加载更多歌手' }}</button>
            </div>
        </section>

        <!-- ===== 歌手详情 ===== -->
        <section v-if="view === 'singerDetail' && curSinger" class="singer-detail">
            <div class="sd-head">
                <img class="sd-img" :src="curSinger.pic" />
                <div class="sd-info">
                    <div class="sd-name">{{ curSinger.name }}</div>
                    <div class="sd-intro">{{ singerIntro || '酷狗歌手' }}</div>
                    <div class="sd-ops">
                        <button class="op-btn play" @click="playAll(singerSongs, curSinger.name + '热门歌曲')">▶ 播放热门</button>
                        <button class="op-btn" @click="loadSingerAlbums()">浏览专辑</button>
                    </div>
                </div>
            </div>
            <div class="chip-row">
                <div class="chip" :class="{ active: singerTab === 'songs' }" @click="singerTab = 'songs'">热门歌曲 ({{ singerSongs.length }})</div>
                <div class="chip" :class="{ active: singerTab === 'albums' }" @click="loadSingerAlbums()">专辑</div>
            </div>
            <template v-if="singerTab === 'songs'">
                <div class="song-table">
                    <div v-for="row in singerSongs" :key="'ss' + row.idx" class="song-row">
                        <div class="col-idx">{{ row.idx }}</div>
                        <div class="col-main">
                            <div class="r-name" :class="{ cur: curRow && curRow.name === row.name && curRow.singer === row.singer && playing }">{{ row.name }}</div>
                            <div class="r-sub">{{ row.singer }}<span v-if="row.album"> · {{ row.album }}</span></div>
                        </div>
                        <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                        <button class="icon-btn play" :disabled="playLoading && curRow && curRow.name === row.name" @click="playOne(row)">
                            {{ playLoading && curRow && curRow.name === row.name ? '…' : (curRow && curRow.name === row.name && playing ? '❚❚' : '▶') }}
                        </button>
                        <button class="icon-btn dl" :disabled="dlBusy[busyKey('ss', row.idx)]" @click="downloadBtn(row, 'ss')">
                            {{ dlBusy[busyKey('ss', row.idx)] ? '…' : '⬇' }}
                        </button>
                    </div>
                </div>
            </template>
            <template v-else>
                <div class="album-grid">
                    <div v-for="a in singerAlbums" :key="a.albumid" class="album-card" @click="openAlbum(a)">
                        <img class="ac-img" :src="a.pic" loading="lazy" />
                        <div class="ac-name">{{ a.name }}</div>
                        <div class="ac-sub">{{ a.pub }}</div>
                    </div>
                </div>
            </template>
        </section>

        <!-- ===== 专辑详情 ===== -->
        <section v-if="view === 'albumDetail'" class="album-detail">
            <div class="tbl-head">
                <div class="th-title">{{ curTitle }}</div>
                <div class="th-sub">{{ curSub }}</div>
                <div v-if="curRows.length" class="th-ops">
                    <button class="op-btn play" @click="playAll(curRows, curTitle)">▶ 播放全部</button>
                    <button v-if="!dlRunning" class="op-btn" @click="downloadAll(curRows, curTitle)">⬇ 下载全部</button>
                    <button v-else class="op-btn stop" @click="dlStop = true">■ 停止 ({{ dlDone }}/{{ dlTotal }})</button>
                </div>
            </div>
            <div v-if="albumLoading" class="loading">加载中…</div>
            <div v-else class="song-table">
                <div v-for="row in curRows" :key="rowsView + row.idx" class="song-row">
                    <div class="col-idx">{{ row.idx }}</div>
                    <div class="col-main">
                        <div class="r-name">{{ row.name }}</div>
                        <div class="r-sub">{{ row.singer }}</div>
                    </div>
                    <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                    <button class="icon-btn play" @click="playOne(row)">▶</button>
                    <button class="icon-btn dl" :disabled="dlBusy[busyKey(rowsView, row.idx)]" @click="downloadBtn(row, rowsView)">
                        {{ dlBusy[busyKey(rowsView, row.idx)] ? '…' : '⬇' }}
                    </button>
                </div>
            </div>
        </section>

        <!-- ===== 歌单广场 ===== -->
        <section v-if="view === 'plaza'" class="plaza-page">
            <div class="chip-row">
                <div v-for="c in QQ_PLAZA_CATS" :key="c.id" class="chip" :class="{ active: plazaCat === c.id }" @click="switchPlaza(c.id)">{{ c.label }}</div>
            </div>
            <div v-if="plazaLoading" class="loading">加载中…</div>
            <div v-else class="diss-grid">
                <div v-for="d in plazaList" :key="d.id" class="diss-card" @click="openDiss(d)">
                    <img class="dc-img" :src="d.pic" loading="lazy" />
                    <div class="dc-name">{{ d.name }}</div>
                    <div class="dc-play">▶ {{ fmtListen(d.listen) }}</div>
                </div>
            </div>
        </section>

        <!-- ===== 歌单详情 / 搜索结果：共用歌曲表 ===== -->
        <section v-if="view === 'dissDetail' || view === 'search'" class="list-detail">
            <div class="tbl-head">
                <div class="th-title">{{ curTitle }}</div>
                <div class="th-sub">{{ curSub }}</div>
                <div v-if="curRows.length" class="th-ops">
                    <button class="op-btn play" @click="playAll(curRows, curTitle)">▶ 播放全部</button>
                    <button v-if="!dlRunning" class="op-btn" @click="downloadAll(curRows, curTitle)">⬇ 下载全部</button>
                    <button v-else class="op-btn stop" @click="dlStop = true">■ 停止 ({{ dlDone }}/{{ dlTotal }})</button>
                </div>
            </div>
            <div v-if="dissLoading || searchLoading" class="loading">解析中…（整单解析约需数秒）</div>
            <div v-else class="song-table">
                <div v-for="row in curRows" :key="rowsView + row.idx" class="song-row">
                    <div class="col-idx">{{ row.idx }}</div>
                    <div class="col-main">
                        <div class="r-name" :class="{ cur: curRow && curRow.name === row.name && curRow.singer === row.singer && playing }">{{ row.name }}</div>
                        <div class="r-sub">{{ row.singer }}<span v-if="row.album"> · {{ row.album }}</span></div>
                    </div>
                    <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                    <button class="icon-btn play" :disabled="playLoading && curRow && curRow.name === row.name" @click="playOne(row)">
                        {{ playLoading && curRow && curRow.name === row.name ? '…' : (curRow && curRow.name === row.name && playing ? '❚❚' : '▶') }}
                    </button>
                    <button class="icon-btn dl" :disabled="dlBusy[busyKey(rowsView, row.idx)]" @click="downloadBtn(row, rowsView)">
                        {{ dlBusy[busyKey(rowsView, row.idx)] ? '…' : '⬇' }}
                    </button>
                </div>
            </div>
        </section>
    </main>

    <!-- ===== 底部播放条 ===== -->
    <footer v-if="curRow" class="player">
        <div class="p-info">
            <div class="p-name">{{ curRow.name }}</div>
            <div class="p-singer">{{ curRow.singer }}<span v-if="curRow.source"> · {{ SOURCE_LABEL[curRow.source] || curRow.source }}</span></div>
        </div>
        <div class="p-ctrl">
            <button class="p-btn" @click="togglePlay">{{ playing ? '❚❚' : '▶' }}</button>
            <button class="p-btn next" @click="playNext">▶▶</button>
            <span class="p-queue">队列 {{ playQueue.length }}</span>
        </div>
        <audio ref="audio" @ended="playNext" @pause="playing = false" @play="playing = true"></audio>
    </footer>
</div>
</template>

<style scoped>
.discover { min-height: 100%; background: #f6f7f9; color: #222; padding-bottom: 92px; }
/* 顶部 */
.hd { position: sticky; top: 0; z-index: 50; background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
.hd-inner { max-width: 1180px; margin: 0 auto; display: flex; align-items: center; gap: 22px; padding: 0 20px; height: 58px; }
.logo { font-size: 19px; font-weight: 700; color: #31c27c; cursor: pointer; white-space: nowrap; }
.nav { display: flex; gap: 4px; flex: 1; }
.nav-item { padding: 6px 14px; border-radius: 16px; font-size: 14px; cursor: pointer; color: #444; }
.nav-item:hover { background: #eef2f5; }
.nav-item.active { color: #31c27c; font-weight: 600; background: #e8f8f0; }
.search-box { display: flex; align-items: center; background: #f1f3f5; border-radius: 18px; padding: 3px 4px 3px 14px; width: 300px; }
.search-box input { border: none; outline: none; background: transparent; flex: 1; font-size: 13px; }
.s-btn { border: none; background: #31c27c; color: #fff; border-radius: 14px; padding: 5px 14px; font-size: 12px; cursor: pointer; }
/* 主体 */
.bd { max-width: 1180px; margin: 0 auto; padding: 18px 20px; }
.backbar { display: inline-block; margin-bottom: 12px; color: #555; cursor: pointer; font-size: 14px; padding: 4px 10px; border-radius: 6px; background: #fff; }
.backbar:hover { color: #31c27c; }
/* 首页 */
.hero { background: linear-gradient(120deg, #31c27c, #2aa8e6); border-radius: 14px; color: #fff; padding: 30px 34px; margin-bottom: 24px; }
.hero-t { font-size: 26px; font-weight: 700; margin-bottom: 8px; }
.hero-d { font-size: 14px; opacity: .92; }
.sec-t { font-size: 17px; margin: 22px 0 12px; }
.sec-more { font-size: 12px; color: #31c27c; cursor: pointer; margin-left: 8px; font-weight: 400; }
.card-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; }
.rank-card { background: #fff; border-radius: 12px; padding: 18px; cursor: pointer; box-shadow: 0 1px 3px rgba(0,0,0,.05); transition: .15s; }
.rank-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,.1); }
.rc-icon { font-size: 24px; color: #31c27c; margin-bottom: 8px; }
.rc-name { font-weight: 600; font-size: 15px; margin-bottom: 4px; }
.rc-go { font-size: 12px; color: #999; }
.singer-row { display: flex; gap: 18px; overflow-x: auto; padding-bottom: 6px; }
.singer-cell { text-align: center; cursor: pointer; flex: 0 0 auto; width: 86px; }
.singer-cell.big { width: 110px; }
.sc-img { width: 84px; height: 84px; border-radius: 50%; object-fit: cover; background: #e5e8eb; }
.singer-cell.big .sc-img { width: 104px; height: 104px; }
.sc-name { font-size: 13px; margin-top: 6px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.diss-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 14px; }
.diss-card { background: #fff; border-radius: 10px; overflow: hidden; cursor: pointer; box-shadow: 0 1px 3px rgba(0,0,0,.05); transition: .15s; }
.diss-card:hover { transform: translateY(-2px); }
.dc-img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; background: #e5e8eb; }
.dc-name { font-size: 13px; padding: 8px 10px 2px; height: 34px; overflow: hidden; line-height: 17px; }
.dc-play { font-size: 11px; color: #999; padding: 0 10px 10px; }
/* 排行榜 */
.ranks-page { display: flex; gap: 18px; }
.rk-side { width: 190px; flex: 0 0 auto; background: #fff; border-radius: 12px; padding: 12px; max-height: 640px; overflow-y: auto; }
.rk-glabel { font-size: 12px; color: #999; margin: 10px 6px 4px; }
.rk-item { font-size: 13px; padding: 6px 10px; border-radius: 6px; cursor: pointer; color: #444; }
.rk-item:hover { background: #eef8f2; }
.rk-item.active { background: #e8f8f0; color: #31c27c; font-weight: 600; }
.rk-main { flex: 1; min-width: 0; }
/* 通用表格 */
.tbl-head { background: #fff; border-radius: 12px 12px 0 0; padding: 16px 18px 12px; }
.th-title { font-size: 19px; font-weight: 700; }
.th-sub { font-size: 12px; color: #999; margin-top: 3px; }
.th-ops { margin-top: 10px; display: flex; gap: 10px; }
.op-btn { border: 1px solid #d8dde2; background: #fff; color: #444; border-radius: 16px; padding: 6px 16px; font-size: 13px; cursor: pointer; }
.op-btn:hover { border-color: #31c27c; color: #31c27c; }
.op-btn.play { background: #31c27c; border-color: #31c27c; color: #fff; }
.op-btn.play:hover { background: #2ba96b; }
.op-btn.stop { border-color: #fa5c5c; color: #fa5c5c; }
.song-table { background: #fff; border-radius: 0 0 12px 12px; overflow: hidden; }
.song-row { display: flex; align-items: center; gap: 12px; padding: 9px 18px; border-top: 1px solid #f2f4f6; }
.song-row:hover { background: #f7faf9; }
.col-idx { width: 28px; text-align: center; color: #bbb; font-style: italic; font-weight: 600; flex: 0 0 auto; }
.song-row:nth-child(-n+3) .col-idx { color: #fa5c5c; }
.col-main { flex: 1; min-width: 0; }
.r-name { font-size: 14px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.r-name.cur { color: #31c27c; }
.r-sub { font-size: 12px; color: #999; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.col-dur { width: 44px; text-align: right; color: #999; font-size: 12px; flex: 0 0 auto; }
.icon-btn { width: 32px; height: 32px; border-radius: 50%; border: 1px solid #dfe3e8; background: #fff; cursor: pointer; font-size: 13px; color: #555; flex: 0 0 auto; }
.icon-btn:hover { background: #31c27c; border-color: #31c27c; color: #fff; }
.icon-btn.play { color: #31c27c; }
.icon-btn.play:hover { color: #fff; }
.icon-btn:disabled { opacity: .5; cursor: wait; }
.loading { background: #fff; padding: 40px; text-align: center; color: #999; border-radius: 0 0 12px 12px; }
.more-area { text-align: center; padding: 14px 0 4px; }
/* 歌手 */
.chip-row { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
.chip { padding: 5px 14px; border-radius: 15px; background: #fff; border: 1px solid #e2e6ea; font-size: 13px; cursor: pointer; color: #555; }
.chip:hover { border-color: #31c27c; color: #31c27c; }
.chip.active { background: #31c27c; border-color: #31c27c; color: #fff; }
.singer-grid { display: grid; grid-template-columns: repeat(9, 1fr); gap: 14px; }
.singer-detail .sd-head { display: flex; gap: 22px; background: #fff; border-radius: 12px; padding: 20px; margin-bottom: 14px; }
.sd-img { width: 130px; height: 130px; border-radius: 50%; object-fit: cover; background: #e5e8eb; }
.sd-name { font-size: 22px; font-weight: 700; }
.sd-intro { font-size: 13px; color: #888; margin: 8px 0 12px; line-height: 1.6; max-width: 700px; }
.sd-ops { display: flex; gap: 10px; }
/* 专辑 */
.album-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 14px; }
.album-card { background: #fff; border-radius: 10px; overflow: hidden; cursor: pointer; box-shadow: 0 1px 3px rgba(0,0,0,.05); transition: .15s; }
.album-card:hover { transform: translateY(-2px); }
.ac-img { width: 100%; aspect-ratio: 1; object-fit: cover; display: block; background: #e5e8eb; }
.ac-name { font-size: 13px; padding: 8px 10px 2px; height: 34px; overflow: hidden; line-height: 17px; }
.ac-sub { font-size: 11px; color: #999; padding: 0 10px 10px; }
/* 播放条 */
.player { position: fixed; left: 0; right: 0; bottom: 0; background: #fff; box-shadow: 0 -2px 10px rgba(0,0,0,.08); z-index: 100; display: flex; align-items: center; gap: 18px; padding: 10px 26px; }
.p-info { width: 260px; min-width: 0; }
.p-name { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.p-singer { font-size: 12px; color: #999; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.p-ctrl { display: flex; align-items: center; gap: 10px; }
.p-btn { width: 40px; height: 40px; border-radius: 50%; border: none; background: #31c27c; color: #fff; font-size: 14px; cursor: pointer; }
.p-btn:hover { background: #2ba96b; }
.p-btn.next { background: #fff; border: 1px solid #d8dde2; color: #444; width: 34px; height: 34px; font-size: 11px; }
.p-queue { font-size: 12px; color: #999; }
/* 移动端 */
@media (max-width: 860px) {
    .card-grid { grid-template-columns: repeat(2, 1fr); }
    .diss-grid { grid-template-columns: repeat(2, 1fr); }
    .singer-grid { grid-template-columns: repeat(4, 1fr); }
    .album-grid { grid-template-columns: repeat(3, 1fr); }
    .ranks-page { flex-direction: column; }
    .rk-side { width: auto; max-height: 200px; }
    .search-box { width: 150px; }
    .col-dur { display: none; }
}
</style>
