<template>
  <div class="lx-embed">
    <div class="lx-bar">
      <span class="lx-title">♫ 发现音乐 · 洛雪播放器</span>
      <span class="lx-desc">五源搜索 / 播放 / 下载 · 支持洛雪自定义音源</span>
      <span class="lx-flex"></span>
      <n-button size="tiny" quaternary @click="openNewWindow">新窗口打开</n-button>
    </div>
    <iframe
      class="lx-frame"
      src="/lx/"
      allow="autoplay; clipboard-write; encrypted-media; fullscreen"
      referrerpolicy="no-referrer"
    ></iframe>
  </div>
</template>

<script>
import { defineComponent, ref, onMounted } from 'vue'
import { NButton } from 'naive-ui'

/**
 * 发现页（v5）：整页嵌入 lxserver（洛雪同步服务端 Web 播放器）。
 * 旧版多源聚合门户逻辑已全部移除。
 * 数据面（搜索/播放/下载/音源/收藏）全部由 lxserver 容器提供：
 *   - 页面与静态资源：/lx/（PLAYER_PATH=/lx）
 *   - 播放器 API：/api/music/{cache,custom,search,...}（nginx 白名单分派）
 *   - Subsonic：/rest/
 * sqmusic 后端 /api/music/{searchSong,getDownloadUrl,...} 不受影响。
 */
export default defineComponent({
  name: 'V3Discover',
  components: { NButton },
  setup() {
    const ready = ref(false)
    onMounted(() => { ready.value = true })
    const openNewWindow = () => {
      window.open('/lx/', '_blank')
    }
    return { ready, openNewWindow }
  },
})
</script>

<style scoped>
.lx-embed {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  background: #fff;
  z-index: 100;
}
.lx-bar {
  height: 44px;
  flex: none;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 16px;
  background: #fafafc;
  border-bottom: 1px solid #ececee;
}
.lx-title {
  font-weight: 700;
  font-size: 14px;
  color: #31c27c;
}
.lx-desc {
  font-size: 12px;
  color: #9a9aa2;
}
.lx-flex {
  flex: 1;
}
.lx-frame {
  flex: 1;
  width: 100%;
  border: 0;
  background: #fff;
}
</style>
