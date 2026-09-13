<script setup>
// ============ SQMusic 发现页（洛雪风格 UI） ============
// 布局致敬洛雪音乐：左侧窄导航（搜索/榜单/歌单）+ 主区列表视图
// 全链路匿名：榜单/歌单数据走 /qq/ 代理（nginx 注入 Referer），歌单详情走后端匿名解析，下载走后端洛雪源
import { ref, computed } from "vue";
import axios from "axios";
import {
    musicSearch,
    musicDownload,
    parserUrlInfo,
    parserUrlAndDownload
} from "../utils/api.js";

// ---------- QQ fcg 代理（nginx /qq/ → c.y.qq.com，自动带 Referer） ----------
const qq = axios.create({ baseURL: "/qq", timeout: 20000 });
const qqGet = async (path, params) => {
    const res = await qq.get(path, { params });
    return typeof res.data === "string" ? JSON.parse(res.data.replace(/^\w+\(|\)$/g, "")) : res.data;
};

// ---------- 视图切换 ----------
const view = ref("search"); // search | top | plaza
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

// 音质标签（洛雪风格 128k/320k/无损/Hi-Res）
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
    // 按品质从高到低展示
    const order = ["Hi-Res", "无损", "320K", "128K"];
    return tags.sort((a, b) => order.indexOf(a) - order.indexOf(b));
};

// ---------- 歌曲表统一行结构 ----------
// {idx, name, singer, album, duration, pic, brTypes, raw}
const toRows = (list) => list.map((m, i) => ({
    idx: i + 1,
    id: m.id || m.mid || "",
    name: m.musicName || m.name || (m.data ? m.data.songname : "") || "",
    singer: Array.isArray(m.musicArtists) ? m.musicArtists.join("/")
        : (m.singer ? (Array.isArray(m.singer) ? m.singer.map(x => x.name).join("/") : m.singer)
            : (m.data ? (m.data.singer || []).map(x => x.name).join("/") : "")),
    album: m.musicAlbum || m.albumname || (m.data ? m.data.albumname : "") || "",
    duration: m.musicDuration || m.duration || (m.data ? m.data.interval : 0) || 0,
    pic: m.musicImage || m.pic || "",
    brTypes: m.bits || m.brTypes || [],
    raw: m
}));

// ---------- 下载（后端原生数据直传 musicDownload） ----------
const pickBr = (row) => {
    const bts = row.brTypes || [];
    return bts.length ? bts[0] : null;
};

const downloadOne = async (song) => {
    if (song.raw) {
        const row = song.raw.plugName ? song.raw : {
            id: song.id, name: song.name, artistName: song.singer, artistids: "",
            pic: song.pic, albumName: song.album, lyric: "", lyricId: song.id,
            plugName: "qq", duration: song.duration, brTypes: song.brTypes
        };
        const br = pickBr(row);
        if (!br) throw new Error("无可下载码率");
        const res = await musicDownload(JSON.parse(JSON.stringify(row)), br);
        if (!res.data || res.data.code !== 200) throw new Error(res.data?.msg || "下载失败");
        return;
    }
    // 榜单行（仅名称）：搜索换取后端原生 songData
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
        topSongs.value = toRows((j.songlist || []).map(s => ({
            data: s.data || {}
        })));
    } catch (e) {
        window.$message.error("榜单详情加载失败：" + (e.message || e));
    }
    topSongsLoading.value = false;
};

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
const plazaView = ref("grid"); // grid | detail

// ---------- 歌单详情（后端匿名解析，无需登录） ----------
const curDiss = ref(null);
const dissSongs = ref([]);
const dissLoading = ref(false);
const dissError = ref("");

const dissUrl = (id) => "https://y.qq.com/n/ryqq/playlist/" + id;

const openDiss = async (d) => {
    curDiss.value = d;
    plazaView.value = "detail";
    dissSongs.value = [];
    dissError.value = "";
    dissLoading.value = true;
    try {
        const res = await parserUrlInfo(dissUrl(d.id));
        if (res.data && res.data.code === 200) {
            const data = res.data.data || {};
            const musics = data.musics || data.songs || (Array.isArray(data) ? data : []);
            if (musics.length) {
                dissSongs.value = toRows(musics);
            } else {
                dissError.value = "解析到 0 首歌曲，请重试";
            }
        } else {
            dissError.value = (res.data && res.data.msg) || "歌单解析失败，请重试";
        }
    } catch (e) {
        dissError.value = "歌单解析失败，请重试";
    }
    dissLoading.value = false;
};
const backDiss = () => {
    curDiss.value = null;
    dissSongs.value = [];
    dissError.value = "";
    plazaView.value = "grid";
};

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
  <div class="lx-page">
    <!-- 左侧窄导航（洛雪风格） -->
    <aside class="lx-side">
      <div class="lx-side-item" :class="{ active: view === 'search' }" @click="setView('search')">
        <span class="lx-side-icon">🔍</span>
        <span class="lx-side-text">搜索</span>
      </div>
      <div class="lx-side-item" :class="{ active: view === 'top' }" @click="setView('top'); loadTops()">
        <span class="lx-side-icon">🏆</span>
        <span class="lx-side-text">榜单</span>
      </div>
      <div class="lx-side-item" :class="{ active: view === 'plaza' }" @click="setView('plaza')">
        <span class="lx-side-icon">💿</span>
        <span class="lx-side-text">歌单</span>
      </div>
      <div class="lx-side-footer">LX</div>
    </aside>

    <!-- 主区 -->
    <main class="lx-main">
      <!-- 顶栏：搜索框 + 批量下载状态 -->
      <div class="lx-topbar">
        <div class="lx-search">
          <input
            v-model="searchKw"
            class="lx-search-input"
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
          class="lx-progress"
        >
          {{ dlDone }} / {{ dlTotal }}
        </n-progress>
        <n-button v-if="dlRunning" quaternary type="error" size="small" @click="stopDl">停止</n-button>
      </div>

      <!-- ================= 搜索视图 ================= -->
      <section v-if="view === 'search'" class="lx-view">
        <div class="lx-toolbar">
          <n-h4 style="margin:0">搜索结果{{ searchKw ? "：" + searchKw : "" }}</n-h4>
          <n-button v-if="searchSongs.length" size="small" type="primary" :loading="dlRunning"
                    @click="downloadAll(searchSongs, searchKw)">
            下载全部（{{ searchSongs.length }} 首）
          </n-button>
        </div>
        <n-spin :show="searchLoading">
          <n-empty v-if="!searchSongs.length && !searchLoading && !searchError" description="输入关键词搜索歌曲"
                   style="margin-top:60px" />
          <n-alert v-if="searchError" type="warning" style="margin-bottom:12px">{{ searchError }}</n-alert>
          <div v-if="searchSongs.length" class="lx-table-wrap">
            <table class="lx-table">
              <thead>
                <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                    <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op">操作</th></tr>
              </thead>
              <tbody>
                <tr v-for="s in searchSongs" :key="s.id + s.idx" class="lx-row">
                  <td class="col-idx">{{ s.idx }}</td>
                  <td>
                    <div class="lx-song">
                      <img v-if="s.pic" class="lx-pic" :src="s.pic" loading="lazy" alt=""/>
                      <div class="lx-song-text">
                        <div class="lx-song-name">{{ s.name }}</div>
                        <div class="lx-song-artist">{{ s.singer }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="col-album lx-ellipsis">{{ s.album }}</td>
                  <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                  <td class="col-br">
                    <span v-for="t in brTags(s.brTypes)" :key="t" class="lx-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                  </td>
                  <td class="col-op">
                    <n-button size="tiny" type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </n-spin>
      </section>

      <!-- ================= 榜单视图 ================= -->
      <section v-if="view === 'top'" class="lx-view lx-split">
        <div class="lx-split-left">
          <n-spin :show="topsLoading">
            <n-alert v-if="topsError" type="warning" style="margin-bottom:8px">{{ topsError }}</n-alert>
            <div class="lx-toplist">
              <div v-for="t in tops" :key="t.id" class="lx-toplist-item"
                   :class="{ active: curTop && curTop.id === t.id }" @click="openTop(t)">
                <img class="lx-toplist-pic" :src="t.pic" loading="lazy" alt=""/>
                <div class="lx-toplist-text">
                  <div class="lx-song-name">{{ t.title }}</div>
                  <div class="lx-song-artist">听听 {{ fmtListen(t.listen) }}</div>
                </div>
              </div>
            </div>
          </n-spin>
        </div>
        <div class="lx-split-right">
          <div class="lx-toolbar">
            <n-h4 style="margin:0">{{ curTop ? curTop.title : "选择榜单" }}</n-h4>
            <n-button v-if="topSongs.length" size="small" type="primary" :loading="dlRunning"
                      @click="downloadAll(topSongs, curTop.title)">
              下载全榜（{{ topSongs.length }} 首）
            </n-button>
          </div>
          <n-spin :show="topSongsLoading">
            <div v-if="topSongs.length" class="lx-table-wrap">
              <table class="lx-table">
                <thead>
                  <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                      <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op">操作</th></tr>
                </thead>
                <tbody>
                  <tr v-for="s in topSongs" :key="s.id + s.idx" class="lx-row">
                    <td class="col-idx">{{ s.idx }}</td>
                    <td>
                      <div class="lx-song">
                        <img v-if="s.pic" class="lx-pic" :src="s.pic" loading="lazy" alt=""/>
                        <div class="lx-song-text">
                          <div class="lx-song-name">{{ s.name }}</div>
                          <div class="lx-song-artist">{{ s.singer }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="col-album lx-ellipsis">{{ s.album }}</td>
                    <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                    <td class="col-br">
                      <span v-for="t in brTags(s.brTypes)" :key="t" class="lx-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                    </td>
                    <td class="col-op">
                      <n-button size="tiny" type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
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
      <section v-if="view === 'plaza'" class="lx-view">
        <!-- 歌单详情 -->
        <template v-if="plazaView === 'detail' && curDiss">
          <div class="lx-toolbar">
            <n-button quaternary size="small" @click="backDiss">← 返回广场</n-button>
            <n-h4 style="margin:0">{{ curDiss.name }}</n-h4>
            <n-button v-if="dissSongs.length" size="small" type="primary" :loading="dlRunning"
                      @click="downloadAll(dissSongs, curDiss.name)">
              下载全部（{{ dissSongs.length }} 首）
            </n-button>
            <n-button size="small" @click="dissBlindDownload">后台解析整单</n-button>
          </div>
          <n-spin :show="dissLoading">
            <n-alert v-if="dissError" type="warning" style="margin-bottom:12px">
              {{ dissError }}
              <n-button size="tiny" style="margin-left:8px" @click="openDiss(curDiss)">重试</n-button>
            </n-alert>
            <div v-if="dissSongs.length" class="lx-table-wrap">
              <table class="lx-table">
                <thead>
                  <tr><th class="col-idx">#</th><th>歌曲</th><th class="col-album">专辑</th>
                      <th class="col-dur">时长</th><th class="col-br">音质</th><th class="col-op">操作</th></tr>
                </thead>
                <tbody>
                  <tr v-for="s in dissSongs" :key="s.id + s.idx" class="lx-row">
                    <td class="col-idx">{{ s.idx }}</td>
                    <td>
                      <div class="lx-song">
                        <img v-if="s.pic" class="lx-pic" :src="s.pic" loading="lazy" alt=""/>
                        <div class="lx-song-text">
                          <div class="lx-song-name">{{ s.name }}</div>
                          <div class="lx-song-artist">{{ s.singer }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="col-album lx-ellipsis">{{ s.album }}</td>
                    <td class="col-dur">{{ fmtDur(s.duration) }}</td>
                    <td class="col-br">
                      <span v-for="t in brTags(s.brTypes)" :key="t" class="lx-br" :class="{ hl: t !== '128K' }">{{ t }}</span>
                    </td>
                    <td class="col-op">
                      <n-button size="tiny" type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </n-spin>
        </template>

        <!-- 广场网格 -->
        <template v-else>
          <div class="lx-cats">
            <n-button v-for="c in plazaCats" :key="c.id" size="small"
                      :type="plazaCat === c.id ? 'primary' : 'default'" :loading="plazaLoading && plazaCat === c.id"
                      @click="switchCat(c.id)">{{ c.label }}</n-button>
          </div>
          <n-alert v-if="plazaError" type="warning" style="margin-bottom:12px">{{ plazaError }}</n-alert>
          <n-spin :show="plazaLoading">
            <div class="lx-grid">
              <div v-for="d in plazaList" :key="d.id" class="lx-card" @click="openDiss(d)">
                <img class="lx-card-pic" :src="d.pic" loading="lazy" alt=""/>
                <div class="lx-card-text">
                  <div class="lx-song-name">{{ d.name }}</div>
                  <div class="lx-song-artist">播放 {{ fmtListen(d.listen) }}</div>
                </div>
              </div>
            </div>
            <div class="lx-pager" v-if="plazaList.length">
              <n-button quaternary size="small" :disabled="plazaPage <= 1" @click="loadPlaza(plazaPage - 1)">上一页</n-button>
              <span class="lx-pager-text">第 {{ plazaPage }} 页</span>
              <n-button quaternary size="small" :disabled="plazaList.length < PAGE_SIZE" @click="loadPlaza(plazaPage + 1)">下一页</n-button>
            </div>
          </n-spin>
        </template>
      </section>
    </main>
  </div>
</template>

<style scoped>
.lx-page {
  display: flex;
  height: calc(100vh - 120px);
  min-height: 520px;
  border-radius: 10px;
  overflow: hidden;
  background: rgba(128, 128, 128, 0.06);
}

/* ---------- 左侧导航 ---------- */
.lx-side {
  width: 76px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 14px 0;
  gap: 6px;
  border-right: 1px solid rgba(128, 128, 128, 0.15);
}
.lx-side-item {
  width: 62px;
  padding: 9px 0;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  cursor: pointer;
  user-select: none;
  transition: background 0.15s;
  border-left: 3px solid transparent;
}
.lx-side-item:hover {
  background: rgba(47, 211, 116, 0.1);
}
.lx-side-item.active {
  background: rgba(47, 211, 116, 0.14);
  border-left-color: #2fd374;
}
.lx-side-icon {
  font-size: 18px;
  line-height: 1;
}
.lx-side-text {
  font-size: 11px;
  opacity: 0.75;
}
.lx-side-footer {
  margin-top: auto;
  font-weight: 700;
  font-size: 12px;
  color: #2fd374;
  opacity: 0.85;
}

/* ---------- 主区 ---------- */
.lx-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}
.lx-topbar {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 16px;
  border-bottom: 1px solid rgba(128, 128, 128, 0.12);
}
.lx-search {
  display: flex;
  gap: 8px;
  flex: 1;
  max-width: 460px;
}
.lx-search-input {
  flex: 1;
  height: 30px;
  padding: 0 12px;
  border-radius: 15px;
  border: 1px solid rgba(128, 128, 128, 0.3);
  background: transparent;
  color: inherit;
  font-size: 13px;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.lx-search-input:focus {
  border-color: #2fd374;
  box-shadow: 0 0 0 2px rgba(47, 211, 116, 0.18);
}
.lx-progress {
  flex: 1;
  min-width: 140px;
}

.lx-view {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 12px 16px 24px;
}
.lx-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

/* ---------- 歌曲表（洛雪样式） ---------- */
.lx-table-wrap {
  overflow: auto;
}
.lx-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.lx-table th {
  text-align: left;
  font-weight: 500;
  opacity: 0.55;
  padding: 6px 8px;
  border-bottom: 1px solid rgba(128, 128, 128, 0.18);
  white-space: nowrap;
}
.lx-table td {
  padding: 7px 8px;
  vertical-align: middle;
}
.lx-row td {
  border-bottom: 1px solid rgba(128, 128, 128, 0.07);
}
.lx-row:hover {
  background: rgba(47, 211, 116, 0.07);
}
.col-idx { width: 42px; opacity: 0.6; }
.col-album { width: 200px; }
.col-dur { width: 64px; opacity: 0.75; }
.col-br { width: 150px; }
.col-op { width: 76px; }
.lx-ellipsis {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  opacity: 0.8;
}
.lx-song {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}
.lx-pic {
  width: 38px;
  height: 38px;
  border-radius: 5px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}
.lx-song-text { min-width: 0; }
.lx-song-name {
  font-weight: 500;
  font-size: 13px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.lx-song-artist {
  font-size: 11px;
  opacity: 0.6;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.lx-br {
  display: inline-block;
  font-size: 10px;
  line-height: 1;
  padding: 3px 5px;
  border-radius: 3px;
  margin-right: 4px;
  border: 1px solid rgba(128, 128, 128, 0.35);
  opacity: 0.7;
}
.lx-br.hl {
  color: #2fd374;
  border-color: rgba(47, 211, 116, 0.55);
  opacity: 1;
}

/* ---------- 榜单分栏 ---------- */
.lx-split {
  display: flex;
  gap: 16px;
  overflow: hidden;
}
.lx-split-left {
  width: 250px;
  flex-shrink: 0;
  overflow: auto;
}
.lx-split-right {
  flex: 1;
  min-width: 0;
  overflow: auto;
}
.lx-toplist {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.lx-toplist-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 7px 8px;
  border-radius: 8px;
  cursor: pointer;
  border-left: 3px solid transparent;
}
.lx-toplist-item:hover {
  background: rgba(47, 211, 116, 0.1);
}
.lx-toplist-item.active {
  background: rgba(47, 211, 116, 0.14);
  border-left-color: #2fd374;
}
.lx-toplist-pic {
  width: 44px;
  height: 44px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}

/* ---------- 歌单广场 ---------- */
.lx-cats {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}
.lx-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
  gap: 12px;
}
.lx-card {
  display: flex;
  gap: 10px;
  align-items: center;
  padding: 8px;
  border-radius: 10px;
  cursor: pointer;
  border: 1px solid rgba(128, 128, 128, 0.12);
  transition: background 0.15s, border-color 0.15s;
}
.lx-card:hover {
  background: rgba(47, 211, 116, 0.08);
  border-color: rgba(47, 211, 116, 0.4);
}
.lx-card-pic {
  width: 64px;
  height: 64px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}
.lx-card-text {
  min-width: 0;
}
.lx-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 16px;
}
.lx-pager-text {
  margin: 0 12px;
  font-size: 13px;
  opacity: 0.7;
}
</style>
