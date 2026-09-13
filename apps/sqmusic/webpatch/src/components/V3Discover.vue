<script setup>
// ============ SQMusic 发现页（QQ音乐网页版风格 UI） ============
// 布局致敬 y.qq.com：顶部导航（首页/排行榜/搜索）+ 榜单歌曲表格直接展示
// 每首歌曲行尾对应下载按钮；全链路匿名：榜单走 /qq/ 代理（nginx 注入 Referer）
// 下载：榜单行走"搜索换票"（后端搜索拿原生数据）→ POST /api/download/downloadSong
import { ref, computed } from "vue";
import axios from "axios";
import {
    musicSearch,
    musicDownload
} from "../utils/api.js";

// ---------- QQ fcg 代理（nginx /qq/ → c.y.qq.com，自动带 Referer） ----------
const qq = axios.create({ baseURL: "/qq", timeout: 20000 });
const qqGet = async (path, params) => {
    const res = await qq.get(path, { params });
    return typeof res.data === "string" ? JSON.parse(res.data.replace(/^\w+\(|\)$/g, "")) : res.data;
};

// ---------- 视图切换 ----------
const view = ref("home"); // home | top | search
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

// 音质标签（歌曲名后小徽标）
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

// 单曲下载状态（行尾按钮转圈）
const dlBusy = ref({}); // key: view+idx -> true
const busyKey = (viewName, idx) => viewName + "#" + idx;

const downloadBtn = async (song, viewName = "home") => {
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
    view.value = "search";
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
    } catch (e) {
        topsError.value = "榜单加载失败：" + (e.message || e);
    }
    topsLoading.value = false;
};

const openTop = async (t, targetView) => {
    curTop.value = t;
    topSongs.value = [];
    topSongsLoading.value = true;
    if (targetView) view.value = targetView;
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
const gotoTop = (t) => { loadTops(); openTop(t, "top"); };

// ================= 首页分区榜单（QQ 音乐网页版四大榜，id 已按 fcg_myqq_toplist 实测校准） =================
const homeSections = [
    { id: 62, title: "飙升榜" },
    { id: 26, title: "热歌榜" },
    { id: 27, title: "新歌榜" },
    { id: 4, title: "流行指数榜" }
];
const homeData = ref({}); // topid -> {songs, loading}
const HOME_COUNT = 10;

const loadHomeSection = async (sec) => {
    if (homeData.value[sec.id] && homeData.value[sec.id].songs.length) return;
    homeData.value = { ...homeData.value, [sec.id]: { songs: [], loading: true } };
    try {
        const j = await qqGet("/v8/fcg-bin/fcg_v8_toplist_cp.fcg", {
            topid: sec.id, type: "top", song_num: HOME_COUNT,
            format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0, platform: "yqq.json", needNewCode: 0
        });
        const songs = toRows((j.songlist || []).map(s => ({ data: s.data || {} })));
        homeData.value = { ...homeData.value, [sec.id]: { songs, loading: false } };
    } catch (e) {
        homeData.value = { ...homeData.value, [sec.id]: { songs: [], loading: false, error: true } };
    }
};
const loadHome = () => { homeSections.forEach(loadHomeSection); };
loadHome();
</script>

<template>
    <div class="yqq">
        <!-- 顶部导航（QQ音乐网页版风格） -->
        <header class="yqq-header">
            <div class="header-inner">
                <div class="logo" @click="setView('home')">
                    <span class="logo-icon">♫</span>
                    <span class="logo-text">发现音乐</span>
                </div>
                <nav class="nav-tabs">
                    <div class="nav-tab" :class="{ active: view === 'home' }" @click="setView('home')">首页</div>
                    <div class="nav-tab" :class="{ active: view === 'top' }" @click="gotoTop(tops[0] || { id: 62, title: '飙升榜' })">排行榜</div>
                </nav>
                <div class="search-box">
                    <svg class="search-ico" viewBox="0 0 24 24" width="16" height="16">
                        <circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"/>
                        <line x1="16.5" y1="16.5" x2="21" y2="21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                    <input
                        v-model="searchKw"
                        placeholder="搜索歌曲、歌手"
                        @keyup.enter="doSearch"
                    />
                </div>
            </div>
        </header>

        <!-- 首页：分区榜单歌曲表格 -->
        <main v-if="view === 'home'" class="yqq-main">
            <section v-for="sec in homeSections" :key="sec.id" class="home-section">
                <div class="section-head">
                    <h2 class="section-title">{{ sec.title }}</h2>
                    <a class="section-more" @click.prevent="gotoTop({ id: sec.id, title: sec.title })">
                        更多
                        <svg viewBox="0 0 24 24" width="12" height="12"><path d="M9 6l6 6-6 6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </a>
                </div>
                <div class="song-table" v-if="homeData[sec.id] && homeData[sec.id].songs.length">
                    <div v-for="row in homeData[sec.id].songs" :key="sec.id + '-' + row.idx" class="song-row">
                        <div class="col-idx" :class="{ top3: row.idx <= 3 }">{{ row.idx }}</div>
                        <div class="col-title">
                            <img class="song-cover" :src="row.pic" loading="lazy" @error="$event.target.style.visibility='hidden'"/>
                            <div class="song-name-wrap">
                                <span class="song-name" :title="row.name">{{ row.name }}</span>
                                <span v-for="t in brTags(row.brTypes)" :key="t" class="br-tag">{{ t }}</span>
                            </div>
                        </div>
                        <div class="col-singer" :title="row.singer">{{ row.singer }}</div>
                        <div class="col-album" :title="row.album">{{ row.album }}</div>
                        <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                        <div class="col-op">
                            <button
                                class="dl-btn"
                                :title="'下载 ' + row.name"
                                :class="{ busy: dlBusy[busyKey('home', row.idx)] }"
                                @click="downloadBtn(row, 'home')"
                            >
                                <svg viewBox="0 0 24 24" width="15" height="15">
                                    <path d="M12 3v12m0 0l-4.5-4.5M12 15l4.5-4.5M4 20h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
                <div v-else class="section-loading">加载中…</div>
            </section>
        </main>

        <!-- 排行榜：左列表右歌曲表格 -->
        <main v-else-if="view === 'top'" class="yqq-main top-layout">
            <aside class="top-side">
                <div class="side-title">榜单</div>
                <div v-if="topsLoading" class="side-loading">加载中…</div>
                <div v-else-if="topsError" class="side-loading">{{ topsError }}</div>
                <div
                    v-for="t in tops"
                    :key="t.id"
                    class="side-item"
                    :class="{ active: curTop && curTop.id === t.id }"
                    @click="openTop(t)"
                >
                    <img class="side-cover" :src="t.pic" loading="lazy" @error="$event.target.style.visibility='hidden'"/>
                    <div class="side-info">
                        <div class="side-name">{{ t.title }}</div>
                        <div class="side-listen">{{ fmtListen(t.listen) }} 收听</div>
                    </div>
                </div>
            </aside>
            <div class="top-content">
                <div class="top-head" v-if="curTop">
                    <h2 class="top-title">{{ curTop.title }}</h2>
                    <button v-if="topSongs.length" class="dl-all-btn" @click="downloadAll(topSongs, curTop.title)">
                        <svg viewBox="0 0 24 24" width="14" height="14"><path d="M12 3v12m0 0l-4.5-4.5M12 15l4.5-4.5M4 20h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        下载全部
                    </button>
                    <button v-if="dlRunning" class="dl-stop-btn" @click="stopDl">停止</button>
                    <span v-if="dlRunning" class="dl-progress">{{ dlDone }}/{{ dlTotal }}</span>
                </div>
                <div v-if="topSongsLoading" class="section-loading">加载中…</div>
                <div class="song-table" v-else-if="topSongs.length">
                    <div v-for="row in topSongs" :key="'top-' + row.idx" class="song-row">
                        <div class="col-idx" :class="{ top3: row.idx <= 3 }">{{ row.idx }}</div>
                        <div class="col-title">
                            <img class="song-cover" :src="row.pic" loading="lazy" @error="$event.target.style.visibility='hidden'"/>
                            <div class="song-name-wrap">
                                <span class="song-name" :title="row.name">{{ row.name }}</span>
                                <span v-for="t in brTags(row.brTypes)" :key="t" class="br-tag">{{ t }}</span>
                            </div>
                        </div>
                        <div class="col-singer" :title="row.singer">{{ row.singer }}</div>
                        <div class="col-album" :title="row.album">{{ row.album }}</div>
                        <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                        <div class="col-op">
                            <button
                                class="dl-btn"
                                :title="'下载 ' + row.name"
                                :class="{ busy: dlBusy[busyKey('top', row.idx)] }"
                                @click="downloadBtn(row, 'top')"
                            >
                                <svg viewBox="0 0 24 24" width="15" height="15">
                                    <path d="M12 3v12m0 0l-4.5-4.5M12 15l4.5-4.5M4 20h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- 搜索结果 -->
        <main v-else-if="view === 'search'" class="yqq-main">
            <div class="top-head">
                <h2 class="top-title">“{{ searchKw }}” 的搜索结果</h2>
            </div>
            <div v-if="searchLoading" class="section-loading">搜索中…</div>
            <div v-else-if="searchError" class="section-loading">{{ searchError }}</div>
            <div class="song-table" v-else-if="searchSongs.length">
                <div v-for="row in searchSongs" :key="'s-' + row.idx" class="song-row">
                    <div class="col-idx">{{ row.idx }}</div>
                    <div class="col-title">
                        <img class="song-cover" :src="row.pic" loading="lazy" @error="$event.target.style.visibility='hidden'"/>
                        <div class="song-name-wrap">
                            <span class="song-name" :title="row.name">{{ row.name }}</span>
                            <span v-for="t in brTags(row.brTypes)" :key="t" class="br-tag">{{ t }}</span>
                        </div>
                    </div>
                    <div class="col-singer" :title="row.singer">{{ row.singer }}</div>
                    <div class="col-album" :title="row.album">{{ row.album }}</div>
                    <div class="col-dur">{{ fmtDur(row.duration) }}</div>
                    <div class="col-op">
                        <button
                            class="dl-btn"
                            :title="'下载 ' + row.name"
                            :class="{ busy: dlBusy[busyKey('search', row.idx)] }"
                            @click="downloadBtn(row, 'search')"
                        >
                            <svg viewBox="0 0 24 24" width="15" height="15">
                                <path d="M12 3v12m0 0l-4.5-4.5M12 15l4.5-4.5M4 20h16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </main>

        <footer class="yqq-footer">SQMusic 发现页 · 数据来源 QQ 音乐榜单 · 歌曲可一键下载入库 NAS</footer>
    </div>
</template>

<style scoped>
.yqq {
    min-height: 100vh;
    background: #fff;
    color: #333;
}
/* ---------- 顶部导航 ---------- */
.yqq-header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: #fff;
    border-bottom: 1px solid #eee;
}
.header-inner {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 24px;
    height: 60px;
    display: flex;
    align-items: center;
    gap: 40px;
}
.logo {
    display: flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    user-select: none;
}
.logo-icon {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: #31c27c;
    color: #fff;
    font-size: 17px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.logo-text {
    font-size: 19px;
    font-weight: 700;
    color: #31c27c;
    letter-spacing: 1px;
}
.nav-tabs {
    display: flex;
    gap: 8px;
    height: 100%;
}
.nav-tab {
    padding: 0 18px;
    height: 60px;
    line-height: 60px;
    font-size: 15px;
    color: #444;
    cursor: pointer;
    position: relative;
    user-select: none;
    transition: color 0.2s;
}
.nav-tab:hover { color: #31c27c; }
.nav-tab.active {
    color: #31c27c;
    font-weight: 600;
}
.nav-tab.active::after {
    content: "";
    position: absolute;
    left: 18px;
    right: 18px;
    bottom: 0;
    height: 3px;
    border-radius: 2px 2px 0 0;
    background: #31c27c;
}
.search-box {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f3f3f3;
    border-radius: 18px;
    padding: 0 16px;
    height: 36px;
    width: 240px;
    color: #999;
    transition: box-shadow 0.2s;
}
.search-box:focus-within {
    box-shadow: 0 0 0 1.5px #31c27c inset;
}
.search-box input {
    border: none;
    outline: none;
    background: transparent;
    flex: 1;
    font-size: 13px;
    color: #333;
}
/* ---------- 主体 ---------- */
.yqq-main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 24px 24px 40px;
}
.home-section { margin-bottom: 34px; }
.section-head {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-bottom: 6px;
}
.section-title {
    font-size: 21px;
    font-weight: 700;
    color: #222;
    position: relative;
    padding-left: 12px;
}
.section-title::before {
    content: "";
    position: absolute;
    left: 0;
    top: 5px;
    bottom: 5px;
    width: 4px;
    border-radius: 2px;
    background: #31c27c;
}
.section-more {
    font-size: 13px;
    color: #888;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 2px;
    transition: color 0.2s;
}
.section-more:hover { color: #31c27c; }
.section-loading {
    padding: 28px 0;
    text-align: center;
    color: #aaa;
    font-size: 13px;
}
/* ---------- 歌曲表格（y.qq.com 风格） ---------- */
.song-table {
    border-top: 1px solid #f0f0f0;
}
.song-row {
    display: flex;
    align-items: center;
    height: 52px;
    border-bottom: 1px solid #f0f0f0;
    padding: 0 8px;
    transition: background 0.15s;
}
.song-row:hover { background: #f7faf9; }
.col-idx {
    width: 40px;
    text-align: center;
    font-size: 14px;
    color: #99a;
    font-variant-numeric: tabular-nums;
    flex-shrink: 0;
}
.col-idx.top3 { color: #fa5c5c; font-weight: 700; font-style: italic; }
.col-title {
    flex: 0 0 34%;
    min-width: 0;
    display: flex;
    align-items: center;
    gap: 12px;
    padding-right: 12px;
}
.song-cover {
    width: 40px;
    height: 40px;
    border-radius: 4px;
    object-fit: cover;
    background: #f2f2f2;
    flex-shrink: 0;
}
.song-name-wrap {
    display: flex;
    align-items: center;
    gap: 6px;
    min-width: 0;
    flex-wrap: wrap;
}
.song-name {
    font-size: 14px;
    color: #333;
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 220px;
}
.song-row:hover .song-name { color: #31c27c; }
.br-tag {
    flex-shrink: 0;
    font-size: 10px;
    line-height: 1;
    padding: 3px 4px;
    border: 1px solid #31c27c;
    border-radius: 3px;
    color: #31c27c;
    transform: scale(0.92);
}
.col-singer, .col-album {
    flex: 1;
    min-width: 0;
    font-size: 13px;
    color: #777;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    padding-right: 12px;
}
.song-row:hover .col-singer,
.song-row:hover .col-album { color: #31c27c; }
.col-dur {
    width: 52px;
    text-align: right;
    font-size: 13px;
    color: #999;
    font-variant-numeric: tabular-nums;
    flex-shrink: 0;
}
.col-op {
    width: 56px;
    flex-shrink: 0;
    display: flex;
    justify-content: center;
}
.dl-btn {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    border: 1px solid #ddd;
    background: #fff;
    color: #888;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
}
.dl-btn:hover {
    border-color: #31c27c;
    background: #31c27c;
    color: #fff;
}
.dl-btn.busy {
    border-color: #31c27c;
    color: #31c27c;
    animation: pulse 1s infinite;
    pointer-events: none;
}
@keyframes pulse {
    50% { opacity: 0.45; }
}
/* ---------- 排行榜布局 ---------- */
.top-layout {
    display: flex;
    gap: 28px;
    align-items: flex-start;
}
.top-side {
    flex: 0 0 280px;
    background: #fafbfb;
    border: 1px solid #f0f0f0;
    border-radius: 8px;
    padding: 14px;
    position: sticky;
    top: 76px;
    max-height: calc(100vh - 100px);
    overflow-y: auto;
}
.side-title {
    font-size: 15px;
    font-weight: 700;
    color: #333;
    padding: 4px 8px 10px;
}
.side-loading {
    padding: 16px 8px;
    color: #aaa;
    font-size: 13px;
}
.side-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 6px 8px;
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.15s;
}
.side-item:hover { background: #eef8f3; }
.side-item.active { background: #e2f5ec; }
.side-cover {
    width: 44px;
    height: 44px;
    border-radius: 4px;
    object-fit: cover;
    background: #eee;
    flex-shrink: 0;
}
.side-info { min-width: 0; }
.side-name {
    font-size: 13px;
    color: #333;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.side-item.active .side-name { color: #31c27c; font-weight: 600; }
.side-listen {
    font-size: 11px;
    color: #aaa;
    margin-top: 2px;
}
.top-content { flex: 1; min-width: 0; }
.top-head {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 10px;
}
.top-title {
    font-size: 22px;
    font-weight: 700;
    color: #222;
    padding-left: 12px;
    position: relative;
}
.top-title::before {
    content: "";
    position: absolute;
    left: 0;
    top: 6px;
    bottom: 6px;
    width: 4px;
    border-radius: 2px;
    background: #31c27c;
}
.dl-all-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    height: 32px;
    padding: 0 16px;
    border: none;
    border-radius: 16px;
    background: #31c27c;
    color: #fff;
    font-size: 13px;
    cursor: pointer;
    transition: background 0.2s;
}
.dl-all-btn:hover { background: #2bb56f; }
.dl-stop-btn {
    height: 32px;
    padding: 0 14px;
    border: 1px solid #ddd;
    border-radius: 16px;
    background: #fff;
    color: #666;
    font-size: 13px;
    cursor: pointer;
}
.dl-stop-btn:hover { border-color: #fa5c5c; color: #fa5c5c; }
.dl-progress {
    font-size: 12px;
    color: #999;
    font-variant-numeric: tabular-nums;
}
/* ---------- 页脚 ---------- */
.yqq-footer {
    max-width: 1200px;
    margin: 0 auto;
    padding: 18px 24px 30px;
    text-align: center;
    color: #bbb;
    font-size: 12px;
}

/* ---------- 移动端适配 ---------- */
@media (max-width: 760px) {
    .header-inner { gap: 12px; padding: 0 12px; }
    .nav-tab { padding: 0 10px; }
    .search-box { width: 130px; }
    .yqq-main { padding: 16px 12px 30px; }
    .top-layout { flex-direction: column; }
    .top-side { position: static; max-height: 220px; flex: none; width: 100%; box-sizing: border-box; }
    .col-album, .col-dur { display: none; }
    .col-title { flex: 1; }
    .song-cover { width: 34px; height: 34px; }
    .song-name { max-width: 110px; }
}
</style>
