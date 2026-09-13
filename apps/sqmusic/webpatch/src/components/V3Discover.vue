<script setup>
// ============ SQMusic 发现页（YesPlayMusic 风格 UI） ============
// 布局致敬 YesPlayMusic：左侧图标导航 + 首页 hero/推荐歌单/排行榜 + 大封面歌单详情
// 全链路匿名：榜单/歌单广场走 /qq/ 代理（nginx 注入 Referer），
// 歌单详情 = parserUrlInfo(头部元数据) + parserUrl(完整歌曲列表，可直接下载)，无需扫码登录
import { ref, computed } from "vue";
import axios from "axios";
import {
    musicSearch,
    musicDownload,
    parserUrlInfo,
    parserUrlSongs,
    parserUrlAndDownload
} from "../utils/api.js";

// ---------- QQ fcg 代理（nginx /qq/ → c.y.qq.com，自动带 Referer） ----------
const qq = axios.create({ baseURL: "/qq", timeout: 20000 });
const qqGet = async (path, params) => {
    const res = await qq.get(path, { params });
    return typeof res.data === "string" ? JSON.parse(res.data.replace(/^\w+\(|\)$/g, "")) : res.data;
};

// ---------- 视图切换 ----------
const view = ref("home"); // home | top | plaza | detail
const prevView = ref("home");
const setView = (v) => { view.value = v; };

// ---------- 通用状态 ----------
const dlRunning = ref(false);
const dlStop = ref(false);
const dlDone = ref(0);
const dlTotal = ref(0);
const dlFail = ref(0);

const fmtListen = (n) => {
    const v = Number(n) || 0;
    return v >= 100000000 ? (v / 100000000).toFixed(1) + "亿" : v >= 10000 ? Math.round(v / 10000) + "万" : String(v);
};
const fmtDur = (s) => {
    const t = Number(s) || 0;
    if (!t) return "";
    return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0");
};

// 音质标签（YPM 风格小徽标）
const brTag = (b) => {
    const s = String(b || "").toUpperCase();
    if (s.includes("HIRE") || s.includes("HI_RES")) return "Hi-Res";
    if (s.includes("FLAC") || s.includes("LOSSLESS")) return "无损";
    if (s.includes("320")) return "320K";
    return "128K";
};
const brTags = (bits) => {
    const arr = bits || [];
    const tags = [];
    arr.forEach(b => {
        const t = brTag(b);
        if (!tags.includes(t)) tags.push(t);
    });
    const order = ["Hi-Res", "无损", "320K", "128K"];
    return tags.sort((a, b) => order.indexOf(a) - order.indexOf(b));
};

// ---------- 歌曲行统一结构 ----------
// 兼容三种来源：后端 Music 实体 / fcg 原始行({data:{songmid,...}}) / fcg 榜单行
const toRows = (list) => list.map((m, i) => {
    const d = m.data || {};
    let id = m.id || m.mid || d.songmid || "";
    let pic = m.musicImage || m.pic || "";
    if (!pic && d.albummid) pic = "https://y.gtimg.cn/music/photo_new/T002R300x300M000" + d.albummid + ".jpg";
    return {
        idx: i + 1,
        id,
        name: m.musicName || m.name || d.songname || "",
        singer: Array.isArray(m.musicArtists) ? m.musicArtists.join("/")
            : (m.singer ? (Array.isArray(m.singer) ? m.singer.map(x => x.name).join("/") : m.singer)
                : (d.singer || []).map(x => x.name).join("/")),
        album: m.musicAlbum || m.albumname || d.albumname || "",
        duration: m.musicDuration || m.duration || d.interval || 0,
        pic,
        brTypes: m.bits || m.brTypes || [],
        raw: m
    };
});

// ---------- 下载 ----------
const pickBr = (row) => {
    // 后端 Music 实体序列化键是 bits；本地行结构是 brTypes
    const bts = row.brTypes || row.bits || [];
    return bts.length ? bts[0] : null;
};

const downloadOne = async (song) => {
    if (song.raw && song.raw.plugName) {
        // 后端原生 Music 数据：直接下载
        const br = pickBr(song.raw);
        if (!br) throw new Error("无可下载码率");
        const res = await musicDownload(JSON.parse(JSON.stringify(song.raw)), br);
        if (!res.data || res.data.code !== 200) throw new Error(res.data?.msg || "下载失败");
        return;
    }
    // 榜单行（仅名称）：搜索换票换取后端原生 songData
    const kw = (song.name + " " + song.singer).trim();
    const res = await musicSearch("qq", "music", kw, 5, 1);
    const records = (res.data && res.data.code === 200 && res.data.data && res.data.data.records) || [];
    if (!records.length) throw new Error("未搜索到: " + kw);
    const row = JSON.parse(JSON.stringify(records[0]));
    const br = pickBr(row);
    if (!br) throw new Error("无可下载码率");
    const dres = await musicDownload(row, br);
    if (!dres.data || dres.data.code !== 200) throw new Error(dres.data?.msg || "下载失败");
};

const downloadBtn = async (song) => {
    try {
        await downloadOne(song);
        window.$message.success("已加入下载：" + song.name);
    } catch (e) {
        window.$message.error("下载失败：" + (e.message || e));
    }
};

const downloadAll = async (songs, listName) => {
    if (dlRunning.value) return;
    if (!songs.length) return;
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
            try {
                await downloadOne(s);
            } catch (e) {
                dlFail.value++;
            }
            dlDone.value++;
        }
    };
    await Promise.all([worker(), worker()]);
    dlRunning.value = false;
    if (dlStop.value) {
        window.$message.warning("已停止：完成 " + dlDone.value + "/" + dlTotal.value);
    } else if (dlFail.value) {
        window.$message.warning("批量下载完成，失败 " + dlFail.value + " 首");
    } else {
        window.$message.success("《" + listName + "》全部下载完成");
    }
};
const stopDl = () => { dlStop.value = true; };

// ================= 搜索 =================
const searchKw = ref("");
const searchLoading = ref(false);
const searchError = ref("");
const searchSongs = ref([]);
const doSearch = async () => {
    const kw = searchKw.value.trim();
    if (!kw) return;
    searchLoading.value = true;
    searchError.value = "";
    searchSongs.value = [];
    if (view.value !== "detail") view.value = "search";
    try {
        const res = await musicSearch("qq", "music", kw, 30, 1);
        if (res.data && res.data.code === 200 && res.data.data) {
            const records = res.data.data.records || [];
            if (!records.length) {
                searchError.value = "没有找到相关歌曲";
            } else {
                searchSongs.value = toRows(records);
            }
        } else {
            searchError.value = (res.data && res.data.msg) || "搜索失败";
        }
    } catch (e) {
        searchError.value = "搜索失败：" + (e.message || e);
    }
    searchLoading.value = false;
};

// ================= 榜单 =================
const tops = ref([]);
const topsLoading = ref(false);
const topsError = ref("");
const curTop = ref(null);
const topSongs = ref([]);
const topSongsLoading = ref(false);

const loadTops = async () => {
    if (tops.value.length) return;
    topsLoading.value = true;
    topsError.value = "";
    try {
        const j = await qqGet("/v8/fcg-bin/fcg_myqq_toplist.fcg", {
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0, platform: "yqq.json", needNewCode: 0
        });
        tops.value = ((j.data || {}).topList || []).map(t => ({
            id: t.id,
            title: t.topTitle,
            pic: t.picUrl,
            listen: t.listenCount
        }));
        if (!tops.value.length) topsError.value = "榜单列表为空";
        else if (!curTop.value) openTop(tops.value[0]);
    } catch (e) {
        topsError.value = "榜单加载失败：" + (e.message || e);
    }
    topsLoading.value = false;
};

const openTop = async (t) => {
    curTop.value = t;
    topSongs.value = [];
    topSongsLoading.value = true;
    try {
        const j = await qqGet("/v8/fcg-bin/fcg_v8_toplist_cp.fcg", {
            topid: t.id, type: "top", song_num: 100,
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0, platform: "yqq.json", needNewCode: 0
        });
        topSongs.value = toRows((j.songlist || []).map(s => ({ data: s.data || {} })));
    } catch (e) {
        window.$message.error("榜单详情加载失败：" + (e.message || e));
    }
    topSongsLoading.value = false;
};
const gotoTop = (t) => { view.value = "top"; loadTops(); openTop(t); };

// ================= 歌单广场 =================
const plazaCats = [
    { label: "热门", id: "10000000" },
    { label: "华语", id: "168" },
    { label: "流行", id: "118" },
    { label: "摇滚", id: "149" },
    { label: "民谣", id: "133" },
    { label: "电子", id: "109" },
    { label: "说唱", id: "188" },
    { label: "粤语", id: "197" },
    { label: "日韩", id: "148" },
    { label: "欧美", id: "141" },
    { label: "轻音乐", id: "131" },
    { label: "影视原声", id: "104" },
    { label: "ACG", id: "21" },
    { label: "爵士", id: "92" },
    { label: "古典", id: "136" }
];
const plazaCat = ref("10000000");
const plazaPage = ref(1);
const plazaList = ref([]);
const plazaLoading = ref(false);
const plazaError = ref("");
const PAGE_SIZE = 20;

const loadPlaza = async (page) => {
    plazaPage.value = page;
    plazaLoading.value = true;
    plazaError.value = "";
    try {
        const sin = (page - 1) * PAGE_SIZE;
        const j = await qqGet("/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg", {
            picmid: 1, rnd: Math.random(), g_tk: 732560959, loginUin: 0, hostUin: 0,
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0,
            platform: "yqq.json", needNewCode: 0,
            categoryId: plazaCat.value, sortId: 5, sin: sin, ein: sin + PAGE_SIZE - 1
        });
        plazaList.value = ((j.data || {}).list || []).map(d => ({
            id: String(d.dissid || ""),
            name: d.dissname || "未命名歌单",
            pic: d.imgurl || d.imgv30 || d.picurl || "",
            listen: d.listennum || 0
        }));
        if (!plazaList.value.length) plazaError.value = "该分类暂无数据，换一个分类试试";
    } catch (e) {
        plazaError.value = "歌单广场加载失败：" + (e.message || e);
    }
    plazaLoading.value = false;
};
const switchCat = (id) => { plazaCat.value = id; loadPlaza(1); };

// 首页推荐歌单 = 广场热门前 10
const hotList = computed(() => plazaList.value.slice(0, 10));
// 首页排行榜预览 = 前 8
const hotTops = computed(() => tops.value.slice(0, 8));

// ================= 歌单详情（YPM 大封面页） =================
// 元数据走 parserUrlInfo（名称/封面/数量/描述），歌曲走 parserUrl（完整列表，可直接下载）
const dissUrl = (id) => "https://y.qq.com/n/ryqq/playlist/" + id;

const curDiss = ref(null);        // {id, name, pic, listen, cover, desc, count}
const dissSongs = ref([]);
const dissLoading = ref(false);
const dissError = ref("");

const openDiss = async (d) => {
    prevView.value = view.value === "detail" ? prevView.value : view.value;
    view.value = "detail";
    curDiss.value = { id: d.id, name: d.name || "", pic: d.pic || "", listen: d.listen || 0 };
    dissSongs.value = [];
    dissError.value = "";
    dissLoading.value = true;
    const url = dissUrl(d.id);
    const [metaRes, songsRes] = await Promise.allSettled([parserUrlInfo(url), parserUrlSongs(url)]);
    // 头部元数据（失败不阻塞歌曲列表）
    if (metaRes.status === "fulfilled" && metaRes.value.data && metaRes.value.data.code === 200) {
        const info = metaRes.value.data.data || {};
        if (info.name) curDiss.value.name = info.name;
        if (info.cover) curDiss.value.pic = info.cover;
        if (info.desc) curDiss.value.desc = info.desc;
        curDiss.value.count = info.count || 0;
    }
    // 歌曲列表
    if (songsRes.status === "fulfilled" && songsRes.value.data && songsRes.value.data.code === 200) {
        const data = songsRes.value.data.data;
        const musics = Array.isArray(data) ? data : (data.musics || data.songs || []);
        if (musics.length) {
            dissSongs.value = toRows(musics);
            if (!curDiss.value.count) curDiss.value.count = musics.length;
        } else {
            dissError.value = "解析到 0 首歌曲，请重试";
        }
    } else {
        const msg = (songsRes.status === "fulfilled" && songsRes.value.data && songsRes.value.data.msg) || "";
        dissError.value = msg ? ("解析失败：" + msg) : "歌单解析失败，请重试";
    }
    dissLoading.value = false;
};
const backDiss = () => {
    view.value = prevView.value === "detail" ? "plaza" : prevView.value;
    curDiss.value = null;
    dissSongs.value = [];
    dissError.value = "";
};

// 后台解析整单（不阻塞页面）
const dissBlindDownload = async () => {
    try {
        const res = await parserUrlAndDownload(dissUrl(curDiss.value.id), false, curDiss.value.name, "");
        if (res.data && res.data.code === 200) {
            window.$message.success("解析任务已提交，请到下载页查看进度");
        } else {
            window.$message.error("解析失败：" + ((res.data && res.data.msg) || "请稍后重试"));
        }
    } catch (e) {
        window.$message.error("解析失败，请稍后重试");
    }
};

// ---------- 初始化 ----------
loadTops();
loadPlaza(1);
</script>

<template>
  <div class="ypm-root">
    <!-- ============ 左侧导航（YesPlayMusic 风格） ============ -->
    <aside class="ypm-side">
      <div class="ypm-logo">
        <div class="ypm-logo-badge">SQ</div>
        <div class="ypm-logo-text">音乐发现</div>
      </div>
      <nav class="ypm-nav">
        <div class="ypm-nav-item" :class="{ active: view === 'home' }" @click="setView('home')">
          <svg class="ypm-ico" viewBox="0 0 24 24"><path d="M4 11.5 12 4l8 7.5V20a1 1 0 0 1-1 1h-5v-6h-4v6H5a1 1 0 0 1-1-1v-8.5Z"/></svg>
          <span>发现音乐</span>
        </div>
        <div class="ypm-nav-item" :class="{ active: view === 'top' }" @click="setView('top'); loadTops()">
          <svg class="ypm-ico" viewBox="0 0 24 24"><path d="M5 20V10m7 10V4m7 16v-7" fill="none" stroke-width="2.4" stroke-linecap="round" class="stroke"/></svg>
          <span>排行榜</span>
        </div>
        <div class="ypm-nav-item" :class="{ active: view === 'plaza' || view === 'detail' }" @click="setView('plaza')">
          <svg class="ypm-ico" viewBox="0 0 24 24"><path d="M12 3a9 9 0 1 1-9 9h2a7 7 0 1 0 7-7V3Z"/><circle cx="12" cy="12" r="2.4"/></svg>
          <span>歌单广场</span>
        </div>
      </nav>
      <div class="ypm-side-foot">
        <div class="ypm-foot-line">全链路匿名</div>
        <div class="ypm-foot-line sub">无需扫码登录</div>
      </div>
    </aside>

    <!-- ============ 主区 ============ -->
    <main class="ypm-main">
      <!-- 顶栏：搜索 + 批量下载状态 -->
      <div class="ypm-topbar">
        <div class="ypm-search">
          <svg class="ypm-search-ico" viewBox="0 0 24 24"><path d="M10.5 4a6.5 6.5 0 1 1 0 13 6.5 6.5 0 0 1 0-13Zm5.9 11.8 4 4-1.6 1.6-4-4a8 8 0 0 1-4.3 1.6A8 8 0 1 1 10.5 2a8 8 0 0 1 8 8 8 8 0 0 1-1.6 4.3Z" transform="scale(0.92) translate(1,1)"/></svg>
          <input
            v-model="searchKw"
            class="ypm-search-input"
            type="text"
            placeholder="搜索歌曲 / 歌手（QQ 音乐源）"
            @keyup.enter="doSearch"
          />
          <n-button size="small" type="primary" :loading="searchLoading" @click="doSearch">搜索</n-button>
        </div>
        <n-progress
          v-if="dlRunning || dlDone > 0"
          type="line"
          :percentage="dlTotal ? Math.round(dlDone / dlTotal * 100) : 0"
          indicator-placement="inside"
          processing
          class="ypm-progress"
        >
          {{ dlDone }} / {{ dlTotal }}
        </n-progress>
        <n-button v-if="dlRunning" quaternary type="error" size="small" @click="stopDl">停止</n-button>
      </div>

      <!-- ================= 首页（发现音乐） ================= -->
      <section v-if="view === 'home'" class="ypm-view">
        <div class="ypm-hero">
          <div class="ypm-hero-title">发现音乐</div>
          <div class="ypm-hero-sub">榜单 · 歌单 · 搜索 · 高音质下载，全部匿名直达</div>
          <div class="ypm-hero-actions">
            <n-button round type="primary" @click="setView('plaza')">逛逛歌单广场</n-button>
            <n-button round secondary @click="setView('top')">看看排行榜</n-button>
          </div>
        </div>

        <div class="ypm-section-head">
          <span class="ypm-section-bar"></span>
          <span class="ypm-section-title">推荐歌单</span>
          <span class="ypm-section-more" @click="setView('plaza')">更多 ›</span>
        </div>
        <n-spin :show="plazaLoading">
          <div class="ypm-grid">
            <div v-for="d in hotList" :key="'h'+d.id" class="ypm-card" @click="openDiss(d)">
              <div class="ypm-card-cover-wrap">
                <img class="ypm-card-pic" :src="d.pic" loading="lazy" alt=""/>
                <span class="ypm-card-listen">▶ {{ fmtListen(d.listen) }}</span>
              </div>
              <div class="ypm-card-name">{{ d.name }}</div>
            </div>
          </div>
        </n-spin>

        <div class="ypm-section-head">
          <span class="ypm-section-bar"></span>
          <span class="ypm-section-title">排行榜</span>
          <span class="ypm-section-more" @click="setView('top'); loadTops()">更多 ›</span>
        </div>
        <n-spin :show="topsLoading">
          <div class="ypm-top-row">
            <div v-for="t in hotTops" :key="'t'+t.id" class="ypm-top-card" @click="gotoTop(t)">
              <img class="ypm-top-pic" :src="t.pic" loading="lazy" alt=""/>
              <div class="ypm-top-text">
                <div class="ypm-top-name">{{ t.title }}</div>
                <div class="ypm-top-sub">{{ fmtListen(t.listen) }} 次收听</div>
              </div>
            </div>
          </div>
        </n-spin>
      </section>

      <!-- ================= 榜单视图 ================= -->
      <section v-if="view === 'top'" class="ypm-view ypm-split">
        <div class="ypm-split-left">
          <n-spin :show="topsLoading">
            <n-alert v-if="topsError" type="warning" style="margin-bottom:8px">{{ topsError }}</n-alert>
            <div class="ypm-toplist">
              <div v-for="t in tops" :key="t.id" class="ypm-toplist-item"
                   :class="{ active: curTop && curTop.id === t.id }" @click="openTop(t)">
                <img class="ypm-toplist-pic" :src="t.pic" loading="lazy" alt=""/>
                <div class="ypm-toplist-text">
                  <div class="ypm-top-name">{{ t.title }}</div>
                  <div class="ypm-top-sub">{{ fmtListen(t.listen) }} 次收听</div>
                </div>
              </div>
            </div>
          </n-spin>
        </div>
        <div class="ypm-split-right">
          <div class="ypm-toolbar">
            <span class="ypm-detail-title" style="font-size:18px">{{ curTop ? curTop.title : "选择榜单" }}</span>
            <n-button v-if="topSongs.length" size="small" type="primary" round :loading="dlRunning"
                      @click="downloadAll(topSongs, curTop.title)">
              下载全榜（{{ topSongs.length }} 首）
            </n-button>
          </div>
          <n-spin :show="topSongsLoading">
            <div v-if="topSongs.length" class="ypm-table-wrap">
              <table class="ypm-table">
                <thead>
                  <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                      <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op"></th></tr>
                </thead>
                <tbody>
                  <tr v-for="s in topSongs" :key="s.id + s.idx" class="ypm-row">
                    <td class="col-idx">{{ s.idx }}</td>
                    <td>
                      <div class="ypm-song">
                        <img v-if="s.pic" class="ypm-pic" :src="s.pic" loading="lazy" alt=""/>
                        <div class="ypm-song-text">
                          <div class="ypm-song-name">{{ s.name }}</div>
                          <div class="ypm-song-artist">{{ s.singer }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="col-album ypm-ellipsis">{{ s.album }}</td>
                    <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                    <td class="col-br">
                      <span v-for="t in brTags(s.brTypes)" :key="t" class="ypm-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                    </td>
                    <td class="col-op">
                      <n-button size="tiny" quaternary type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <n-empty v-else-if="!topSongsLoading" description="左侧选择榜单" style="margin-top:60px" />
          </n-spin>
        </div>
      </section>

      <!-- ================= 歌单广场视图 ================= -->
      <section v-if="view === 'plaza'" class="ypm-view">
        <div class="ypm-cats">
          <span v-for="c in plazaCats" :key="c.id" class="ypm-chip"
                :class="{ active: plazaCat === c.id }"
                @click="switchCat(c.id)">{{ c.label }}</span>
        </div>
        <n-alert v-if="plazaError" type="warning" style="margin-bottom:12px">{{ plazaError }}</n-alert>
        <n-spin :show="plazaLoading">
          <div class="ypm-grid">
            <div v-for="d in plazaList" :key="d.id" class="ypm-card" @click="openDiss(d)">
              <div class="ypm-card-cover-wrap">
                <img class="ypm-card-pic" :src="d.pic" loading="lazy" alt=""/>
                <span class="ypm-card-listen">▶ {{ fmtListen(d.listen) }}</span>
              </div>
              <div class="ypm-card-name">{{ d.name }}</div>
            </div>
          </div>
          <div class="ypm-pager" v-if="plazaList.length">
            <n-button quaternary size="small" :disabled="plazaPage <= 1" @click="loadPlaza(plazaPage - 1)">上一页</n-button>
            <span class="ypm-pager-text">第 {{ plazaPage }} 页</span>
            <n-button quaternary size="small" :disabled="plazaList.length < PAGE_SIZE" @click="loadPlaza(plazaPage + 1)">下一页</n-button>
          </div>
        </n-spin>
      </section>

      <!-- ================= 歌单详情（YPM 大封面页） ================= -->
      <section v-if="view === 'detail' && curDiss" class="ypm-view">
        <div class="ypm-back">
          <n-button quaternary size="small" @click="backDiss">‹ 返回</n-button>
        </div>
        <div class="ypm-detail-head">
          <img v-if="curDiss.pic" class="ypm-detail-cover" :src="curDiss.pic" alt=""/>
          <div class="ypm-detail-info">
            <div class="ypm-detail-tag">歌单</div>
            <div class="ypm-detail-title">{{ curDiss.name || "加载中…" }}</div>
            <div class="ypm-detail-meta">
              <span v-if="curDiss.count">共 {{ curDiss.count }} 首</span>
              <span v-if="curDiss.listen">· {{ fmtListen(curDiss.listen) }} 次播放</span>
              <span class="ypm-detail-anon">· 匿名解析无需登录</span>
            </div>
            <div v-if="curDiss.desc" class="ypm-detail-desc">{{ curDiss.desc }}</div>
            <div class="ypm-detail-actions">
              <n-button v-if="dissSongs.length" type="primary" round :loading="dlRunning"
                        @click="downloadAll(dissSongs, curDiss.name)">
                下载全部（{{ dissSongs.length }} 首）
              </n-button>
              <n-button round @click="dissBlindDownload">后台解析整单</n-button>
            </div>
          </div>
        </div>
        <n-spin :show="dissLoading">
          <n-alert v-if="dissError" type="warning" style="margin-bottom:12px">
            {{ dissError }}
            <n-button size="tiny" style="margin-left:8px" @click="openDiss(curDiss)">重试</n-button>
          </n-alert>
          <div v-if="dissSongs.length" class="ypm-table-wrap">
            <table class="ypm-table">
              <thead>
                <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                    <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op"></th></tr>
              </thead>
              <tbody>
                <tr v-for="s in dissSongs" :key="s.id + s.idx" class="ypm-row">
                  <td class="col-idx">{{ s.idx }}</td>
                  <td>
                    <div class="ypm-song">
                      <img v-if="s.pic" class="ypm-pic" :src="s.pic" loading="lazy" alt=""/>
                      <div class="ypm-song-text">
                        <div class="ypm-song-name">{{ s.name }}</div>
                        <div class="ypm-song-artist">{{ s.singer }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="col-album ypm-ellipsis">{{ s.album }}</td>
                  <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                  <td class="col-br">
                    <span v-for="t in brTags(s.brTypes)" :key="t" class="ypm-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                  </td>
                  <td class="col-op">
                    <n-button size="tiny" quaternary type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </n-spin>
      </section>

      <!-- ================= 搜索结果视图 ================= -->
      <section v-if="view === 'search'" class="ypm-view">
        <div class="ypm-toolbar">
          <span class="ypm-detail-title" style="font-size:18px">搜索结果{{ searchKw ? "：" + searchKw : "" }}</span>
          <n-button v-if="searchSongs.length" size="small" type="primary" round :loading="dlRunning"
                    @click="downloadAll(searchSongs, searchKw)">
            下载全部（{{ searchSongs.length }} 首）
          </n-button>
        </div>
        <n-spin :show="searchLoading">
          <n-empty v-if="!searchSongs.length && !searchLoading && !searchError" description="输入关键词搜索歌曲"
                   style="margin-top:60px" />
          <n-alert v-if="searchError" type="warning" style="margin-bottom:12px">{{ searchError }}</n-alert>
          <div v-if="searchSongs.length" class="ypm-table-wrap">
            <table class="ypm-table">
              <thead>
                <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                    <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op"></th></tr>
              </thead>
              <tbody>
                <tr v-for="s in searchSongs" :key="s.id + s.idx" class="ypm-row">
                  <td class="col-idx">{{ s.idx }}</td>
                  <td>
                    <div class="ypm-song">
                      <img v-if="s.pic" class="ypm-pic" :src="s.pic" loading="lazy" alt=""/>
                      <div class="ypm-song-text">
                        <div class="ypm-song-name">{{ s.name }}</div>
                        <div class="ypm-song-artist">{{ s.singer }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="col-album ypm-ellipsis">{{ s.album }}</td>
                  <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                  <td class="col-br">
                    <span v-for="t in brTags(s.brTypes)" :key="t" class="ypm-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                  </td>
                  <td class="col-op">
                    <n-button size="tiny" quaternary type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </n-spin>
      </section>
    </main>
  </div>
</template>

<style scoped>
.ypm-root {
  --ypm-accent: #335eea;
  --ypm-accent-soft: rgba(51, 94, 234, 0.12);
  --ypm-surface: rgba(128, 128, 128, 0.07);
  --ypm-border: rgba(128, 128, 128, 0.14);
  display: flex;
  height: calc(100vh - 120px);
  min-height: 520px;
  border-radius: 12px;
  overflow: hidden;
  background: var(--ypm-surface);
}

/* ---------- 左侧导航 ---------- */
.ypm-side {
  width: 168px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  padding: 18px 12px 14px;
  border-right: 1px solid var(--ypm-border);
}
.ypm-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 6px 18px;
}
.ypm-logo-badge {
  width: 34px;
  height: 34px;
  border-radius: 9px;
  background: linear-gradient(135deg, #335eea, #6a5af9);
  color: #fff;
  font-weight: 800;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 10px rgba(51, 94, 234, 0.35);
}
.ypm-logo-text {
  font-weight: 700;
  font-size: 14px;
  letter-spacing: 1px;
}
.ypm-nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.ypm-nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 10px;
  font-size: 13px;
  cursor: pointer;
  user-select: none;
  opacity: 0.72;
  transition: background 0.15s, opacity 0.15s;
}
.ypm-nav-item:hover { background: var(--ypm-accent-soft); opacity: 1; }
.ypm-nav-item.active {
  background: var(--ypm-accent-soft);
  color: var(--ypm-accent);
  font-weight: 600;
  opacity: 1;
}
.ypm-nav-item.active .ypm-ico, .ypm-nav-item.active .ypm-ico .stroke { fill: var(--ypm-accent); stroke: var(--ypm-accent); }
.ypm-ico { width: 17px; height: 17px; fill: currentColor; flex-shrink: 0; }
.ypm-ico .stroke { stroke: currentColor; fill: none; }
.ypm-side-foot {
  margin-top: auto;
  padding: 0 6px;
}
.ypm-foot-line {
  font-size: 11px;
  color: var(--ypm-accent);
  font-weight: 600;
}
.ypm-foot-line.sub {
  color: inherit;
  opacity: 0.5;
  font-weight: 400;
  margin-top: 2px;
}

/* ---------- 主区 ---------- */
.ypm-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
.ypm-topbar {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 18px;
  border-bottom: 1px solid var(--ypm-border);
}
.ypm-search {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  max-width: 460px;
  position: relative;
}
.ypm-search-ico {
  position: absolute;
  left: 12px;
  width: 15px;
  height: 15px;
  fill: currentColor;
  opacity: 0.45;
  pointer-events: none;
}
.ypm-search-input {
  flex: 1;
  height: 34px;
  padding: 0 12px 0 34px;
  border-radius: 17px;
  border: 1px solid var(--ypm-border);
  background: transparent;
  color: inherit;
  font-size: 13px;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.ypm-search-input:focus {
  border-color: var(--ypm-accent);
  box-shadow: 0 0 0 3px var(--ypm-accent-soft);
}
.ypm-progress { flex: 1; min-width: 140px; }

.ypm-view {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 16px 18px 28px;
}
.ypm-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

/* ---------- 首页 hero ---------- */
.ypm-hero {
  border-radius: 16px;
  padding: 30px 32px;
  background: linear-gradient(135deg, #335eea 0%, #6a5af9 60%, #8f6bff 100%);
  color: #fff;
  margin-bottom: 22px;
  box-shadow: 0 10px 30px rgba(51, 94, 234, 0.28);
}
.ypm-hero-title {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: 1px;
}
.ypm-hero-sub {
  margin-top: 6px;
  font-size: 13px;
  opacity: 0.88;
}
.ypm-hero-actions {
  margin-top: 16px;
  display: flex;
  gap: 10px;
}
.ypm-hero-actions :deep(.n-button--primary-type) { --n-color: #fff; --n-color-hover: #f0f3ff; --n-text-color: #335eea; }

/* ---------- 区块标题 ---------- */
.ypm-section-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 18px 0 12px;
}
.ypm-section-bar {
  width: 4px;
  height: 16px;
  border-radius: 2px;
  background: var(--ypm-accent);
}
.ypm-section-title {
  font-size: 17px;
  font-weight: 700;
}
.ypm-section-more {
  margin-left: auto;
  font-size: 12px;
  opacity: 0.55;
  cursor: pointer;
  user-select: none;
}
.ypm-section-more:hover { color: var(--ypm-accent); opacity: 1; }

/* ---------- 卡片网格 ---------- */
.ypm-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 14px;
}
.ypm-card { cursor: pointer; }
.ypm-card-cover-wrap {
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  background: rgba(128, 128, 128, 0.15);
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.ypm-card:hover .ypm-card-cover-wrap {
  transform: translateY(-3px);
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.18);
}
.ypm-card-pic {
  display: block;
  width: 100%;
  aspect-ratio: 1/1;
  object-fit: cover;
}
.ypm-card-listen {
  position: absolute;
  right: 7px;
  bottom: 7px;
  font-size: 10px;
  color: #fff;
  background: rgba(0, 0, 0, 0.45);
  border-radius: 9px;
  padding: 2px 7px;
  backdrop-filter: blur(3px);
}
.ypm-card-name {
  margin-top: 7px;
  font-size: 12.5px;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ---------- 排行榜横向卡片 ---------- */
.ypm-top-row {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 12px;
}
.ypm-top-card {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 9px;
  border-radius: 12px;
  border: 1px solid var(--ypm-border);
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s, border-color 0.15s;
}
.ypm-top-card:hover {
  transform: translateY(-2px);
  border-color: rgba(51, 94, 234, 0.45);
  box-shadow: 0 8px 18px rgba(51, 94, 234, 0.14);
}
.ypm-top-pic {
  width: 52px;
  height: 52px;
  border-radius: 9px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}
.ypm-top-name {
  font-size: 13px;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.ypm-top-sub {
  font-size: 11px;
  opacity: 0.55;
  margin-top: 2px;
}

/* ---------- 歌曲表（YPM 风格） ---------- */
.ypm-table-wrap { overflow: auto; }
.ypm-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.ypm-table th {
  text-align: left;
  font-weight: 500;
  opacity: 0.5;
  padding: 6px 8px;
  border-bottom: 1px solid var(--ypm-border);
  white-space: nowrap;
}
.ypm-table td { padding: 7px 8px; vertical-align: middle; }
.ypm-row td { border-bottom: 1px solid rgba(128, 128, 128, 0.06); }
.ypm-row:hover { background: var(--ypm-accent-soft); }
.col-idx { width: 42px; opacity: 0.55; }
.col-album { width: 200px; }
.col-dur { width: 64px; opacity: 0.7; }
.col-br { width: 150px; }
.col-op { width: 70px; }
.ypm-ellipsis {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  opacity: 0.75;
}
.ypm-song { display: flex; align-items: center; gap: 10px; min-width: 0; }
.ypm-pic {
  width: 38px;
  height: 38px;
  border-radius: 7px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}
.ypm-song-text { min-width: 0; }
.ypm-song-name {
  font-weight: 500;
  font-size: 13px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.ypm-song-artist {
  font-size: 11px;
  opacity: 0.55;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.ypm-br {
  display: inline-block;
  font-size: 10px;
  line-height: 1;
  padding: 3px 6px;
  border-radius: 8px;
  margin-right: 4px;
  border: 1px solid rgba(128, 128, 128, 0.3);
  opacity: 0.65;
}
.ypm-br.hl {
  color: var(--ypm-accent);
  border-color: rgba(51, 94, 234, 0.5);
  opacity: 1;
  font-weight: 600;
}

/* ---------- 榜单分栏 ---------- */
.ypm-split { display: flex; gap: 16px; overflow: hidden; }
.ypm-split-left { width: 250px; flex-shrink: 0; overflow: auto; }
.ypm-split-right { flex: 1; min-width: 0; overflow: auto; }
.ypm-toplist { display: flex; flex-direction: column; gap: 3px; }
.ypm-toplist-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 7px 8px;
  border-radius: 10px;
  cursor: pointer;
  transition: background 0.15s;
}
.ypm-toplist-item:hover { background: var(--ypm-accent-soft); }
.ypm-toplist-item.active {
  background: var(--ypm-accent-soft);
  box-shadow: inset 3px 0 0 var(--ypm-accent);
}
.ypm-toplist-pic {
  width: 44px;
  height: 44px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}

/* ---------- 歌单广场 chips ---------- */
.ypm-cats {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 14px;
}
.ypm-chip {
  padding: 5px 14px;
  border-radius: 14px;
  font-size: 12.5px;
  border: 1px solid var(--ypm-border);
  cursor: pointer;
  user-select: none;
  opacity: 0.75;
  transition: all 0.15s;
}
.ypm-chip:hover { color: var(--ypm-accent); border-color: rgba(51, 94, 234, 0.5); opacity: 1; }
.ypm-chip.active {
  background: var(--ypm-accent);
  border-color: var(--ypm-accent);
  color: #fff;
  font-weight: 600;
  opacity: 1;
  box-shadow: 0 4px 10px rgba(51, 94, 234, 0.3);
}

/* ---------- 歌单详情（YPM 大封面头部） ---------- */
.ypm-back { margin-bottom: 6px; }
.ypm-detail-head {
  display: flex;
  gap: 22px;
  padding: 6px 0 20px;
}
.ypm-detail-cover {
  width: 180px;
  height: 180px;
  border-radius: 14px;
  object-fit: cover;
  flex-shrink: 0;
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.22);
  background: rgba(128, 128, 128, 0.15);
}
.ypm-detail-info { min-width: 0; display: flex; flex-direction: column; justify-content: center; }
.ypm-detail-tag {
  display: inline-block;
  width: fit-content;
  font-size: 11px;
  color: var(--ypm-accent);
  border: 1px solid rgba(51, 94, 234, 0.5);
  border-radius: 6px;
  padding: 2px 8px;
  margin-bottom: 8px;
  font-weight: 600;
}
.ypm-detail-title {
  font-size: 24px;
  font-weight: 800;
  line-height: 1.3;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}
.ypm-detail-meta {
  margin-top: 8px;
  font-size: 12.5px;
  opacity: 0.65;
}
.ypm-detail-anon { color: var(--ypm-accent); opacity: 1; font-weight: 600; }
.ypm-detail-desc {
  margin-top: 8px;
  font-size: 12px;
  opacity: 0.55;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  max-width: 560px;
}
.ypm-detail-actions { margin-top: 14px; display: flex; gap: 10px; flex-wrap: wrap; }

.ypm-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 18px;
}
.ypm-pager-text { margin: 0 12px; font-size: 13px; opacity: 0.7; }
</style>
