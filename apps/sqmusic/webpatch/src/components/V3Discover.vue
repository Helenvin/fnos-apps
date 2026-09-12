<script setup>
// ============ SQMusic 发现页（QQ 优先） ============
// 榜单：匿名可用（QQ fcg 接口经 /qq/ 代理注入 Referer）
// 歌单广场：匿名浏览；歌单详情/整单下载依赖后端 QQ 扫码登录（设置页）
// 逐首下载：searchSong(qq) 换取后端原生 songData → downloadSong，保证字段兼容
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

// ---------- 通用状态 ----------
const tab = ref("top");
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
    return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0");
};

// ---------- 榜单 ----------
const tops = ref([]);
const topsLoading = ref(false);
const topsError = ref("");
const curTop = ref(null);
const topSongs = ref([]);
const topSongsLoading = ref(false);
const topInfo = computed(() => (curTop.value ? { name: curTop.value.topTitle, pic: curTop.value.picUrl } : null));

const loadTops = async () => {
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
            listen: t.listenCount,
            preview: (t.songList || []).map(s => s.songname + " - " + s.singername)
        }));
        if (!tops.value.length) topsError.value = "榜单列表为空";
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
        topSongs.value = (j.songlist || []).map((s, i) => {
            const d = s.data || {};
            return {
                idx: i + 1,
                name: d.songname || "",
                singer: (d.singer || []).map(x => x.name).join("/"),
                album: d.albumname || "",
                mid: d.songmid || "",
                duration: d.interval || 0,
                sizeflac: d.sizeflac || 0
            };
        });
    } catch (e) {
        window.$message.error("榜单详情加载失败：" + (e.message || e));
    }
    topSongsLoading.value = false;
};
const backTop = () => { curTop.value = null; topSongs.value = []; };

// ---------- 歌单广场 ----------
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

// ---------- 歌单详情（依赖后端 QQ 扫码登录） ----------
const curDiss = ref(null);
const dissName = ref("");
const dissPic = ref("");
const dissSongs = ref([]);
const dissLoading = ref(false);
const dissLoginNeeded = ref(false);

const dissUrl = (id) => "https://y.qq.com/n/ryqq/playlist/" + id;

const openDiss = async (d) => {
    curDiss.value = d;
    dissName.value = d.name;
    dissPic.value = d.pic;
    dissSongs.value = [];
    dissLoginNeeded.value = false;
    dissLoading.value = true;
    try {
        const res = await parserUrlInfo(dissUrl(d.id));
        if (res.data && res.data.code === 200) {
            const data = res.data.data || {};
            const musics = data.musics || data.songs || (Array.isArray(data) ? data : []);
            dissSongs.value = musics.map((m, i) => ({
                idx: i + 1,
                id: m.id,
                name: m.musicName || m.name || "",
                singer: m.musicArtists || (m.singer || []).map(x => x.name).join("/") || "",
                album: m.musicAlbum || m.albumName || "",
                pic: m.musicImage || "",
                duration: m.musicDuration || m.duration || 0,
                brTypes: m.bits || m.brTypes || [],
                raw: m
            }));
            if (!dissSongs.value.length) {
                dissLoginNeeded.value = true;
            }
        } else {
            dissLoginNeeded.value = true;
        }
    } catch (e) {
        dissLoginNeeded.value = true;
    }
    dissLoading.value = false;
};
const backDiss = () => { curDiss.value = null; dissSongs.value = []; dissLoginNeeded.value = false; };

const dissBlindDownload = async () => {
    try {
        const res = await parserUrlAndDownload(dissUrl(curDiss.value.id), false, dissName.value, "");
        if (res.data && res.data.code === 200) {
            window.$message.success("解析任务已提交，请到下载页查看进度");
        } else {
            window.$message.error("解析失败：" + ((res.data && res.data.msg) || "后端可能未完成 QQ 扫码登录"));
        }
    } catch (e) {
        window.$message.error("解析失败，请确认已在设置中完成 QQ 扫码登录");
    }
};

// ---------- 下载（searchSong 换后端原生 songData） ----------
const pickBr = (row) => {
    const bts = row.brTypes || [];
    return bts.length ? bts[0] : null;
};

const downloadOne = async (song) => {
    // song: {name, singer} 或后端原生行
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
        window.$message.warning("批量下载完成，失败 " + dlFail.value + " 首（VIP 歌曲需在设置中 QQ 扫码登录）");
    } else {
        window.$message.success("《" + listName + "》全部下载完成");
    }
};
const stopDl = () => { dlStop.value = true; };

// ---------- 初始化 ----------
loadTops();
loadPlaza(1);
</script>

<template>
  <div class="discover-page">
    <n-tabs v-model:value="tab" type="line" size="large" justify-content="center" animated>
      <!-- ================= 榜单 ================= -->
      <n-tab-pane name="top" tab="QQ 榜单">
        <!-- 榜单详情 -->
        <template v-if="curTop">
          <div class="detail-head">
            <n-button quaternary @click="backTop">← 返回榜单</n-button>
            <n-h3 style="margin:0">{{ topInfo.name }}</n-h3>
            <n-button type="primary" :loading="dlRunning" :disabled="!topSongs.length || dlRunning"
                      @click="downloadAll(topSongs, topInfo.name)">
              一键下载全榜（{{ topSongs.length }} 首）
            </n-button>
            <n-button v-if="dlRunning" quaternary type="error" @click="stopDl">停止</n-button>
          </div>
          <n-progress v-if="dlRunning || dlDone > 0" type="line" :percentage="dlTotal ? Math.round(dlDone / dlTotal * 100) : 0"
                      indicator-placement="inside" processing>
            {{ dlDone }} / {{ dlTotal }}
          </n-progress>
          <n-spin :show="topSongsLoading">
            <n-table v-if="topSongs.length" :bordered="false" :single-line="false" size="small" class="song-table">
              <thead>
                <tr><th style="width:44px">#</th><th>歌曲</th><th style="width:180px">歌手</th>
                    <th style="width:200px">专辑</th><th style="width:64px">时长</th><th style="width:88px">操作</th></tr>
              </thead>
              <tbody>
                <tr v-for="s in topSongs" :key="s.mid + s.idx">
                  <td>{{ s.idx }}</td>
                  <td class="song-name">{{ s.name }}</td>
                  <td>{{ s.singer }}</td>
                  <td>{{ s.album }}</td>
                  <td>{{ fmtDur(s.duration) }}</td>
                  <td>
                    <n-button size="tiny" type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                  </td>
                </tr>
              </tbody>
            </n-table>
          </n-spin>
        </template>

        <!-- 榜单卡片墙 -->
        <template v-else>
          <n-spin :show="topsLoading">
            <n-alert v-if="topsError" type="warning" style="margin-bottom:12px">{{ topsError }}</n-alert>
            <div class="card-grid">
              <n-card v-for="t in tops" :key="t.id" hoverable class="top-card" @click="openTop(t)">
                <div class="card-body">
                  <img class="card-pic" :src="t.pic" loading="lazy" alt=""/>
                  <div class="card-text">
                    <div class="card-title">{{ t.title }}</div>
                    <div class="card-sub">听听 {{ fmtListen(t.listen) }}</div>
                    <div class="card-preview">
                      <div v-for="(p, i) in t.preview.slice(0, 3)" :key="i" class="preview-line">{{ i + 1 }}. {{ p }}</div>
                    </div>
                  </div>
                </div>
              </n-card>
            </div>
          </n-spin>
        </template>
      </n-tab-pane>

      <!-- ================= 歌单广场 ================= -->
      <n-tab-pane name="plaza" tab="歌单广场">
        <!-- 歌单详情 -->
        <template v-if="curDiss">
          <div class="detail-head">
            <n-button quaternary @click="backDiss">← 返回广场</n-button>
            <n-h3 style="margin:0">{{ dissName }}</n-h3>
            <template v-if="!dissLoginNeeded">
              <n-button type="primary" :loading="dlRunning" :disabled="!dissSongs.length || dlRunning"
                        @click="downloadAll(dissSongs, dissName)">
                一键下载全部（{{ dissSongs.length }} 首）
              </n-button>
            </template>
          </div>
          <n-progress v-if="dlRunning || dlDone > 0" type="line" :percentage="dlTotal ? Math.round(dlDone / dlTotal * 100) : 0"
                      indicator-placement="inside" processing>
            {{ dlDone }} / {{ dlTotal }}
          </n-progress>
          <n-spin :show="dissLoading">
            <n-alert v-if="dissLoginNeeded" type="warning" title="需要 QQ 扫码登录"
                     style="margin-bottom:12px">
              腾讯对歌单详情接口做了限制：解析歌单需后端完成 QQ 扫码登录。
              请打开右上角「设置」→「插件管理」→ qqvip 扫码登录后重试；
              或直接一键解析整单下载（同样需要登录）。匿名下载请使用「QQ 榜单」。
              <div style="margin-top:8px">
                <n-button size="small" @click="openDiss(curDiss)">重试</n-button>
                <n-button size="small" type="primary" style="margin-left:8px" @click="dissBlindDownload">一键解析整单下载</n-button>
              </div>
            </n-alert>
            <n-table v-if="dissSongs.length" :bordered="false" :single-line="false" size="small" class="song-table">
              <thead>
                <tr><th style="width:44px">#</th><th>歌曲</th><th style="width:180px">歌手</th>
                    <th style="width:200px">专辑</th><th style="width:64px">时长</th><th style="width:88px">操作</th></tr>
              </thead>
              <tbody>
                <tr v-for="s in dissSongs" :key="s.id + s.idx">
                  <td>{{ s.idx }}</td>
                  <td class="song-name">{{ s.name }}</td>
                  <td>{{ s.singer }}</td>
                  <td>{{ s.album }}</td>
                  <td>{{ fmtDur(s.duration) }}</td>
                  <td>
                    <n-button size="tiny" type="primary" :disabled="dlRunning" @click="downloadBtn(s)">下载</n-button>
                  </td>
                </tr>
              </tbody>
            </n-table>
          </n-spin>
        </template>

        <!-- 广场卡片墙 -->
        <template v-else>
          <div class="plaza-toolbar">
            <n-space>
              <n-button v-for="c in plazaCats" :key="c.id" size="small"
                        :type="plazaCat === c.id ? 'primary' : 'default'" :loading="plazaLoading && plazaCat === c.id"
                        @click="switchCat(c.id)">{{ c.label }}</n-button>
            </n-space>
          </div>
          <n-alert v-if="plazaError" type="warning" style="margin-bottom:12px">{{ plazaError }}</n-alert>
          <n-spin :show="plazaLoading">
            <div class="card-grid">
              <n-card v-for="d in plazaList" :key="d.id" hoverable class="top-card" @click="openDiss(d)">
                <div class="card-body">
                  <img class="card-pic" :src="d.pic" loading="lazy" alt=""/>
                  <div class="card-text">
                    <div class="card-title">{{ d.name }}</div>
                    <div class="card-sub">播放 {{ fmtListen(d.listen) }}</div>
                    <div class="card-preview">
                      <n-tag size="small" :bordered="false" type="info">歌单 {{ d.id }}</n-tag>
                    </div>
                  </div>
                </div>
              </n-card>
            </div>
          </n-spin>
          <div class="plaza-pager" v-if="plazaList.length">
            <n-button quaternary :disabled="plazaPage <= 1" @click="loadPlaza(plazaPage - 1)">上一页</n-button>
            <span style="margin:0 12px">第 {{ plazaPage }} 页</span>
            <n-button quaternary :disabled="plazaList.length < PAGE_SIZE" @click="loadPlaza(plazaPage + 1)">下一页</n-button>
          </div>
        </template>
      </n-tab-pane>
    </n-tabs>
  </div>
</template>

<style scoped>
.discover-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 16px 80px;
}
.detail-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 14px;
}
.card-body {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}
.card-pic {
  width: 96px;
  height: 96px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
  background: rgba(128, 128, 128, 0.15);
}
.card-text {
  min-width: 0;
}
.card-title {
  font-weight: 600;
  font-size: 14px;
  line-height: 1.35;
  margin-bottom: 2px;
  word-break: break-all;
}
.card-sub {
  font-size: 12px;
  opacity: 0.65;
  margin-bottom: 6px;
}
.card-preview {
  font-size: 12px;
  opacity: 0.8;
  line-height: 1.5;
}
.preview-line {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.plaza-toolbar {
  margin-bottom: 12px;
}
.plaza-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 16px;
}
.song-table {
  margin-top: 4px;
}
.song-name {
  font-weight: 500;
}
</style>
