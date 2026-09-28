<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Yellow OS - True Syntax Edition</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&family=Fira+Code:wght@400;500&display=swap');

    :root {
      --yellow-primary: #eab308;
      --yellow-light: #fef08a;       
      --yellow-dark: #ca8a04;        
      
      --cros-shelf-bg: rgba(24, 24, 27, 0.94);
      --cros-card-bg: #27272a;
      --cros-bg-dark: #121212;
      --cros-panel-bg: #1c1c1f;
      --cros-panel-header: #242428;
      --cros-border: #3f3f46;
      --text-main: #f4f4f5;          
      --text-muted: #a1a1aa;         
    }

    * { box-sizing: border-box; user-select: none; -webkit-tap-highlight-color: transparent; }
    body, html {
      margin: 0; padding: 0; width: 100%; height: 100%;
      overflow: hidden; font-family: 'Noto Sans JP', -apple-system, BlinkMacSystemFont, sans-serif;
      color: var(--text-main); background-color: var(--cros-bg-dark);
    }

    #hardware-filter-overlay {
      position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
      pointer-events: none; z-index: 99990; transition: background-color 0.2s ease;
      background-color: transparent;
    }

    /* 起動画面 */
    #boot-screen {
      position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
      background: var(--cros-bg-dark); display: flex; flex-direction: column;
      align-items: center; justify-content: center; z-index: 99999;
      opacity: 1; transition: opacity 0.4s ease, visibility 0.4s ease; pointer-events: none;
    }
    .boot-logo {
      width: clamp(100px, 30vw, 150px); height: auto;
      display: block; margin-bottom: 20px; opacity: 0;
      animation: fadeIn 1.2s ease 0.1s forwards;
    }
    .boot-title {
      font-size: 18px; font-weight: 700; color: var(--yellow-primary);
      letter-spacing: 4px; opacity: 0; animation: fadeIn 1.2s ease 0.3s forwards;
    }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

    /* デスクトップ領域 */
    #desktop {
      width: 100vw; height: calc(100vh - 48px);
      background: var(--cros-bg-dark); position: relative;
      overflow: hidden;
    }

    /* Shelf（タスクバー） */
    #shelf {
      position: absolute; bottom: 0; left: 0; width: 100vw; height: 48px;
      background: var(--cros-shelf-bg); backdrop-filter: blur(20px);
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 8px; z-index: 10000; border-top: 1px solid rgba(255, 255, 255, 0.08);
    }
    .shelf-left { display: flex; align-items: center; gap: 8px; }
    
    .launcher-btn {
      width: 38px; height: 38px; border-radius: 50%; display: flex;
      align-items: center; justify-content: center; cursor: pointer;
      transition: background 0.15s; background: transparent; border: none;
    }
    .launcher-btn:hover { background: rgba(255, 255, 255, 0.1); }
    .launcher-circle {
      width: 16px; height: 16px; border-radius: 50%;
      border: 2px solid var(--text-main); display: flex; align-items: center; justify-content: center;
    }
    .launcher-circle-inner { width: 4px; height: 4px; border-radius: 50%; background: var(--text-main); }

    .shelf-apps { display: flex; align-items: center; gap: 4px; margin-left: 6px; }
    .shelf-app {
      width: 38px; height: 38px; border-radius: 6px; display: flex; flex-direction: column;
      align-items: center; justify-content: center; cursor: pointer; position: relative;
      transition: all 0.15s;
    }
    .shelf-app:hover { background: rgba(255, 255, 255, 0.1); }
    .shelf-app svg { width: 20px; height: 20px; }
    .shelf-indicator {
      position: absolute; bottom: 2px; width: 12px; height: 2.5px; border-radius: 2px;
      background: var(--yellow-primary); display: none;
    }
    .shelf-app.open .shelf-indicator { display: block; }
    .shelf-app.active { background: rgba(255, 255, 255, 0.15); }

    /* ステータストレイ */
    .status-tray {
      display: flex; align-items: center; gap: 8px; height: 36px;
      padding: 0 12px; border-radius: 18px; background: rgba(255, 255, 255, 0.06);
      cursor: pointer; transition: background 0.15s; font-size: 11.5px; font-weight: 500;
    }
    .status-tray:hover { background: rgba(255, 255, 255, 0.12); }
    .status-icons { display: flex; align-items: center; gap: 6px; }
    .status-icons svg { width: 14px; height: 14px; fill: currentColor; }
    .ime-badge { font-size: 11px; font-weight: bold; padding: 1px 4px; border-radius: 3px; background: rgba(255,255,255,0.15); }

    /* ランチャー */
    #cros-launcher {
      position: absolute; bottom: 56px; left: 12px; width: 480px;
      background: rgba(28, 28, 31, 0.98); backdrop-filter: blur(24px);
      border: 1px solid var(--cros-border); border-radius: 14px;
      padding: 16px; display: none; flex-direction: column; gap: 14px;
      z-index: 10001; box-shadow: 0 16px 40px rgba(0,0,0,0.6);
      animation: launcherSlide 0.2s cubic-bezier(0, 0, 0.2, 1);
    }
    @keyframes launcherSlide {
      from { transform: translateY(20px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    .launcher-search-box {
      display: flex; align-items: center; gap: 10px; background: #000;
      border: 1px solid var(--cros-border); padding: 8px 14px; border-radius: 20px;
    }
    .launcher-search-box input {
      flex: 1; background: transparent; border: none; outline: none;
      color: #fff; font-size: 12px;
    }
    .launcher-grid {
      display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px;
      max-height: 380px; overflow-y: auto; padding: 4px;
    }
    .launcher-item {
      display: flex; flex-direction: column; align-items: center; gap: 6px;
      padding: 10px 4px; border-radius: 10px; cursor: pointer; transition: background 0.15s;
    }
    .launcher-item:hover { background: rgba(255, 255, 255, 0.08); }
    .launcher-icon {
      width: 42px; height: 42px; border-radius: 8px; background: var(--yellow-primary);
      color: #000; display: flex; align-items: center; justify-content: center;
    }
    .launcher-icon svg { width: 22px; height: 22px; stroke: #000; }
    .launcher-label { font-size: 11px; text-align: center; }

    /* クイック設定パネル */
    #quick-settings-panel {
      position: absolute; bottom: 56px; right: 12px; width: 330px;
      background: rgba(28, 28, 31, 0.98); backdrop-filter: blur(24px);
      border: 1px solid var(--cros-border); border-radius: 14px;
      padding: 16px; display: none; flex-direction: column; gap: 12px;
      z-index: 10001; box-shadow: 0 16px 40px rgba(0,0,0,0.6);
    }
    .qs-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--cros-border); padding-bottom: 8px; }
    .qs-tiles { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .qs-tile {
      background: var(--cros-card-bg); border: 1px solid var(--cros-border); padding: 8px 10px;
      border-radius: 8px; display: flex; align-items: center; gap: 8px; font-size: 11px;
      cursor: pointer; transition: all 0.15s;
    }
    .qs-tile svg { width: 14px; height: 14px; stroke: currentColor; fill: none; }
    .qs-tile.active { background: var(--yellow-primary); color: #000; font-weight: bold; border-color: var(--yellow-primary); }
    .qs-tile.active svg { stroke: #000; }
    .qs-slider-group { display: flex; align-items: center; gap: 10px; font-size: 12px; }
    .qs-slider-group svg { width: 15px; height: 15px; stroke: currentColor; fill: none; }
    .qs-slider-group input { flex: 1; accent-color: var(--yellow-primary); cursor: pointer; }

    /* ウィンドウ構造 */
    .window {
      position: absolute; width: 780px; height: 520px;
      top: 30px; left: 40px; background: var(--cros-panel-bg); border: 1px solid var(--cros-border);
      border-radius: 8px; display: none; flex-direction: column; overflow: hidden; z-index: 10;
      min-width: 320px; min-height: 240px; resize: both; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      transition: width 0.12s ease, height 0.12s ease, top 0.12s ease, left 0.12s ease;
    }
    .window.maximized {
      top: 0 !important; left: 0 !important;
      width: 100vw !important; height: calc(100vh - 48px) !important;
      border-radius: 0 !important; border: none !important; resize: none !important;
    }
    .window.snap-left {
      top: 0 !important; left: 0 !important;
      width: 50vw !important; height: calc(100vh - 48px) !important;
      border-radius: 0 !important; resize: none !important;
    }
    .window.snap-right {
      top: 0 !important; left: 50vw !important;
      width: 50vw !important; height: calc(100vh - 48px) !important;
      border-radius: 0 !important; resize: none !important;
    }
    
    .window-header {
      background: var(--cros-panel-header); height: 36px; display: flex;
      align-items: center; justify-content: space-between; padding: 0 10px;
      cursor: move; border-bottom: 1px solid var(--cros-border); touch-action: none;
    }
    .window-title { font-size: 12px; font-weight: 500; display: flex; align-items: center; gap: 6px; color: var(--yellow-primary); pointer-events: none; }
    .window-title svg { width: 14px; height: 14px; stroke: currentColor; fill: none; }
    .window-controls { display: flex; gap: 4px; }
    .win-btn {
      width: 24px; height: 24px; background: transparent; border: none;
      color: var(--text-muted); cursor: pointer; border-radius: 4px; font-size: 11px;
      display: flex; align-items: center; justify-content: center; transition: background 0.1s;
    }
    .win-btn:hover { background: rgba(255, 255, 255, 0.1); color: var(--text-main); }
    .close-btn:hover { background: #dc2626 !important; color: #fff !important; }
    .window-body { flex: 1; padding: 8px; background: var(--cros-bg-dark); display: flex; flex-direction: column; gap: 8px; overflow: hidden; }

    /* =========================================================
       Studio IDE & シンタックスハイライト（完全同期オーバーレイ）
    ========================================================= */
    .ide-container { display: flex; flex-direction: column; height: 100%; width: 100%; gap: 6px; }
    .ide-toolbar {
      display: flex; flex-wrap: wrap; gap: 6px; align-items: center; justify-content: space-between;
      background: var(--cros-panel-header); padding: 4px 8px; border-radius: 6px; border: 1px solid var(--cros-border);
    }
    .ide-toolbar-group { display: flex; gap: 6px; align-items: center; }

    .ide-btn {
      background: var(--cros-card-bg); border: 1px solid var(--cros-border); color: var(--text-main);
      padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; cursor: pointer;
      display: flex; align-items: center; gap: 4px; transition: all 0.15s;
    }
    .ide-btn:hover { background: var(--cros-border); }
    .ide-btn-primary { background: var(--yellow-primary); color: #000; border-color: var(--yellow-primary); }
    .ide-btn-primary:hover { background: var(--yellow-dark); border-color: var(--yellow-dark); }
    
    .ide-select {
      background: var(--cros-card-bg); border: 1px solid var(--cros-border); color: var(--text-main);
      font-size: 11px; padding: 4px 6px; border-radius: 4px; outline: none;
    }

    .ide-workspace { flex: 1; display: flex; gap: 6px; min-height: 0; position: relative; }
    .editor-wrapper { flex: 1; display: flex; flex-direction: column; position: relative; min-width: 0; }
    
    .syntax-editor-container {
      position: relative; flex: 1; width: 100%; height: 100%; background: #0c0c0e;
      border: 1px solid var(--cros-border); border-radius: 6px; overflow: hidden;
    }
    .syntax-editor-container:focus-within { border-color: var(--yellow-primary); }

    /* 背景と前面でピクセル単位で完全に一致させるスタイル設定 */
    .code-layer {
      position: absolute; top: 0; left: 0; width: 100%; height: 100%;
      margin: 0; padding: 12px; border: none; outline: none;
      font-family: 'Fira Code', Consolas, 'Courier New', monospace;
      font-size: 13px; line-height: 1.6; tab-size: 2; -moz-tab-size: 2;
      white-space: pre; word-wrap: normal; overflow: auto; box-sizing: border-box;
      letter-spacing: 0px;
    }

    #highlighting {
      pointer-events: none; z-index: 1; background: transparent; user-select: none;
    }
    #highlighting-content {
      font-family: inherit; font-size: inherit; line-height: inherit;
    }

    #html-code {
      color: transparent; background: transparent; caret-color: #ffffff; z-index: 2; resize: none;
    }

    /* 正確な構文ハイライトカラー */
    .hl-bracket { color: #38bdf8; }                      /* <, >, </, /> (シアン) */
    .hl-tagname { color: var(--yellow-primary); font-weight: bold; } /* html, body, div, script等 (イエロー) */
    .hl-attr { color: #67e8f9; }                         /* lang, charset, class, onclick等 (ライトシアン) */
    .hl-str { color: #4ade80; }                          /* "文字列" (グリーン) */
    .hl-keyword { color: #c084fc; font-weight: bold; }   /* function, return, let等 (パープル) */
    .hl-builtin { color: #60a5fa; }                      /* console, document等 (ブルー) */
    .hl-comment { color: #71717a; font-style: italic; }  /* <!-- コメント --> (グレー) */

    #autocomplete-box {
      position: absolute; display: none; flex-direction: column; z-index: 1000;
      background: #18181b; border: 1px solid var(--yellow-primary); border-radius: 6px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.6); max-height: 180px; width: 220px;
      overflow-y: auto; font-family: 'Fira Code', monospace; font-size: 11px;
    }
    .suggest-item {
      padding: 5px 8px; cursor: pointer; display: flex; justify-content: space-between;
      color: var(--text-main); border-bottom: 1px solid #27272a;
    }
    .suggest-item:hover, .suggest-item.active { background: var(--yellow-primary); color: #000; font-weight: bold; }
    .suggest-type { font-size: 9px; opacity: 0.7; text-transform: uppercase; }

    .preview-wrapper { flex: 1; display: flex; flex-direction: column; min-width: 0; }
    .preview-frame { flex: 1; background: #ffffff; border: 1px solid var(--cros-border); border-radius: 6px; width: 100%; height: 100%; }

    .ide-terminal-panel {
      height: 130px; background: #000; border: 1px solid var(--cros-border);
      border-radius: 6px; display: flex; flex-direction: column; overflow: hidden;
      transition: height 0.2s ease;
    }
    .ide-terminal-header {
      background: #18181b; padding: 4px 8px; display: flex; align-items: center;
      justify-content: space-between; border-bottom: 1px solid var(--cros-border);
      font-size: 11px; font-weight: 700; color: var(--yellow-primary);
    }
    .terminal-output {
      flex: 1; background: #000; color: #4ade80; font-family: 'Fira Code', monospace;
      padding: 6px 10px; overflow-y: auto; font-size: 11px; line-height: 1.45;
      user-select: text;
    }
    .terminal-log-error { color: #f87171; }
    .terminal-input-bar {
      display: flex; align-items: center; background: #000; padding: 4px 8px;
      border-top: 1px solid #27272a; font-family: 'Fira Code', monospace;
    }
    .terminal-prompt { color: #38bdf8; font-size: 11px; font-weight: bold; margin-right: 6px; }
    .terminal-input { flex: 1; background: transparent; border: none; outline: none; color: #fff; font-family: inherit; font-size: 11.5px; }

    /* 電卓 */
    .calc-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; height: 100%; }
    .calc-screen {
      grid-column: span 4; background: #000; color: var(--yellow-primary); font-family: monospace;
      font-size: 24px; font-weight: bold; text-align: right; padding: 12px; border-radius: 6px;
      display: flex; align-items: center; justify-content: flex-end; border: 1px solid var(--cros-border);
    }
    .calc-btn {
      background: var(--cros-card-bg); border: 1px solid var(--cros-border); color: var(--text-main);
      font-size: 14px; font-weight: 500; border-radius: 6px; cursor: pointer; display: flex;
      align-items: center; justify-content: center; transition: background 0.1s;
    }
    .calc-btn:hover { background: var(--cros-border); }

    /* メモ帳 */
    .notepad-textarea {
      flex: 1; width: 100%; background: #000; color: #fff; font-family: monospace;
      font-size: 12.5px; line-height: 1.5; padding: 10px; border: 1px solid var(--cros-border);
      border-radius: 6px; resize: none; outline: none; user-select: text;
    }

    /* ペイント */
    .paint-toolbar { display: flex; gap: 8px; align-items: center; background: var(--cros-panel-header); padding: 6px; border-radius: 6px; border: 1px solid var(--cros-border); }
    #paint-canvas { flex: 1; background: #ffffff; border-radius: 6px; cursor: crosshair; touch-action: none; }

    /* ファイルエクスプローラー */
    .explorer-container { display: flex; height: 100%; gap: 8px; }
    .explorer-sidebar { width: 150px; background: var(--cros-panel-header); border: 1px solid var(--cros-border); border-radius: 6px; padding: 8px; display: flex; flex-direction: column; gap: 4px; }
    .explorer-nav-item { padding: 6px 8px; border-radius: 4px; font-size: 11px; cursor: pointer; color: var(--text-muted); }
    .explorer-nav-item.active, .explorer-nav-item:hover { background: var(--cros-card-bg); color: var(--yellow-primary); font-weight: bold; }
    .explorer-main { flex: 1; background: #000; border: 1px solid var(--cros-border); border-radius: 6px; padding: 10px; display: flex; flex-direction: column; gap: 8px; }
    .file-item { display: flex; align-items: center; justify-content: space-between; padding: 6px 10px; background: var(--cros-card-bg); border-radius: 4px; font-size: 11.5px; cursor: pointer; }
    .file-item:hover { background: #333; }

    /* タスクマネージャー */
    .taskmgr-table { width: 100%; border-collapse: collapse; font-size: 11px; text-align: left; }
    .taskmgr-table th, .taskmgr-table td { padding: 8px; border-bottom: 1px solid var(--cros-border); }
    .taskmgr-table th { background: var(--cros-panel-header); color: var(--yellow-primary); }

    /* クロック */
    .clock-display { font-size: 44px; font-weight: 700; color: var(--yellow-primary); text-align: center; margin: 16px 0; font-family: monospace; }

    /* 付箋 */
    .sticky-note-area {
      flex: 1; width: 100%; background: #26241a; color: var(--yellow-light);
      border: 1px solid var(--yellow-dark); border-radius: 6px; padding: 10px;
      font-size: 13px; outline: none; resize: none; user-select: text;
    }

    /* トースト通知 */
    #toast-container { position: absolute; bottom: 56px; right: 16px; display: flex; flex-direction: column; gap: 6px; z-index: 99999; pointer-events: none; }
    .toast {
      background: var(--cros-panel-bg); border-left: 4px solid var(--yellow-primary); color: var(--text-main);
      padding: 8px 14px; border-radius: 6px; font-size: 12px; border: 1px solid var(--cros-border);
      animation: slideIn 0.2s ease, fadeOut 0.4s ease 2.5s forwards;
    }
    @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    @keyframes fadeOut { to { opacity: 0; transform: translateY(6px); } }

    @media (max-width: 600px) {
      .window:not(.maximized):not(.snap-left):not(.snap-right) { width: 96vw; height: 75vh; top: 10px !important; left: 2vw !important; }
      .ide-workspace { flex-direction: column; }
    }
  </style>
</head>
<body>

  <div id="hardware-filter-overlay"></div>

  <!-- 起動画面 -->
  <div id="boot-screen">
    <img class="boot-logo" src="Gemini_Generated_Image_alwbx1alwbx1alwb-removebg-preview.png" alt="Yellow OS Logo">
    <div class="boot-title">YELLOW OS</div>
  </div>

  <div id="desktop"></div>

  <!-- ランチャー -->
  <div id="cros-launcher">
    <div class="launcher-search-box">
      <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="text" id="launcher-search" placeholder="端末とアプリを検索..." oninput="filterLauncher(this.value)">
    </div>
    <div class="launcher-grid" id="launcher-grid">
      <div class="launcher-item" onclick="openWindow('win-studio'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></div>
        <div class="launcher-label">Studio IDE</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-notepad'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
        <div class="launcher-label">メモ帳</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-paint'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg></div>
        <div class="launcher-label">ペイント</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-explorer'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></div>
        <div class="launcher-label">ファイル</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-calc'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><rect x="4" y="2" width="16" height="20" rx="2"/></svg></div>
        <div class="launcher-label">電卓</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-browser'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg></div>
        <div class="launcher-label">ブラウザ</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-taskmgr'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 12h3l2-5 3 10 2-5h2"/></svg></div>
        <div class="launcher-label">タスク管理</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-clock'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <div class="launcher-label">クロック</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-sticky'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><path d="M16 2H4a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8z"/></svg></div>
        <div class="launcher-label">付箋</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-media'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg></div>
        <div class="launcher-label">プレイヤー</div>
      </div>
      <div class="launcher-item" onclick="openWindow('win-settings'); toggleLauncher();">
        <div class="launcher-icon"><svg viewBox="0 0 24 24" fill="none" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></div>
        <div class="launcher-label">設定</div>
      </div>
    </div>
  </div>

  <!-- クイック設定パネル -->
  <div id="quick-settings-panel">
    <div class="qs-header">
      <div>
        <div style="font-weight:700; font-size:12px; color:var(--yellow-primary);">Quick Settings</div>
        <div id="qs-real-date" style="font-size:10.5px; color:var(--text-muted); margin-top:2px;">日付取得中...</div>
      </div>
      <div style="display:flex; gap:6px;">
        <button class="win-btn" onclick="toggleOSFullscreen()" title="全画面">
          <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/></svg>
        </button>
        <button class="win-btn" onclick="openWindow('win-settings'); toggleQuickSettings();" title="設定">
          <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </button>
        <button class="win-btn" onclick="location.reload()" title="再読み込み">
          <svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
        </button>
      </div>
    </div>
    
    <div class="qs-tiles">
      <div class="qs-tile active" id="tile-network">
        <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2"><path d="M5 12.55a11 11 0 0 1 14.08 0M1.42 9a16 16 0 0 1 21.16 0M8.53 16.11a6 6 0 0 1 6.95 0M12 20h.01"/></svg>
        <span id="tile-net-text">Wi-Fi (接続中)</span>
      </div>
      <div class="qs-tile" id="tile-bluetooth" onclick="triggerRealBluetooth()">
        <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2"><polyline points="6.5 6.5 17.5 17.5 12 23 12 1 17.5 6.5 6.5 17.5"/></svg>
        <span>Bluetooth</span>
      </div>
      <div class="qs-tile" id="tile-nightlight" onclick="toggleNightLight()">
        <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
        <span>夜間モード</span>
      </div>
      <div class="qs-tile" id="tile-fullscreen" onclick="toggleOSFullscreen()">
        <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" fill="none" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/></svg>
        <span>全画面表示</span>
      </div>
    </div>

    <div class="qs-slider-group">
      <svg id="vol-svg" viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" fill="none" stroke-width="2"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"/></svg>
      <input type="range" id="real-vol-slider" min="0" max="100" value="80" oninput="changeRealVolume(this.value)">
    </div>

    <div class="qs-slider-group">
      <svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" fill="none" stroke-width="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
      <input type="range" id="real-bright-slider" min="20" max="100" value="100" oninput="changeRealBrightness(this.value)">
    </div>

    <div id="qs-real-battery" style="font-size:11px; color:var(--text-muted); text-align:right;">
      バッテリー情報取得中...
    </div>
  </div>

  <!-- Studio IDE -->
  <div id="win-studio" class="window" style="top:20px; left:25px; width:920px; height:620px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-studio')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" width="14" height="14" stroke-width="2.5"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
        Studio IDE & Console
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-studio')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-studio')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-studio')">x</button>
      </div>
    </div>
    
    <div class="window-body">
      <div class="ide-container">
        <div class="ide-toolbar">
          <div class="ide-toolbar-group">
            <button class="ide-btn ide-btn-primary" onclick="renderHTML()">実行</button>
            <label style="font-size:11px; display:flex; align-items:center; gap:4px; color:var(--text-muted); cursor:pointer;">
              <input type="checkbox" id="live-preview-toggle" onchange="toggleLiveMode()"> Live更新
            </label>
            <select class="ide-select" onchange="loadTemplate(this.value); this.value='';">
              <option value="">テンプレート...</option>
              <option value="counter">カウンター</option>
              <option value="game">Canvas ゲーム</option>
              <option value="ui">カードUI</option>
            </select>
          </div>

          <div class="ide-toolbar-group">
            <button class="ide-btn" onclick="downloadCode()">保存</button>
            <label class="ide-btn" style="cursor:pointer;">
              読込
              <input type="file" accept=".html,.txt" onchange="uploadCode(event)" style="display:none;">
            </label>
            <select id="ide-view-mode" class="ide-select" onchange="changeViewMode(this.value)">
              <option value="split">左右分割</option>
              <option value="code">コードのみ</option>
              <option value="preview">プレビューのみ</option>
            </select>
            <button class="ide-btn" onclick="toggleTerminalPanel()">ターミナル</button>
          </div>
        </div>

        <div class="ide-workspace">
          <div class="editor-wrapper" id="editor-wrapper">
            <div class="syntax-editor-container">
              <pre id="highlighting" class="code-layer" aria-hidden="true"><code id="highlighting-content"></code></pre>
              <textarea id="html-code" class="code-layer" spellcheck="false"
                oninput="handleEditorInput()"
                onkeydown="handleEditorKeyDown(event)"
                onscroll="syncEditorScroll()"><!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: sans-serif; background: #121212; color: #fff; padding: 20px; }
    h2 { color: #eab308; }
    button { background: #eab308; border: none; padding: 8px 16px; font-weight: bold; border-radius: 4px; cursor: pointer; }
  </style>
</head>
<body>
  <h2>Yellow Studio IDE</h2>
  <p>下のボタンを押すとコンソールにログが出力されます。</p>
  <button onclick="testLog()">ログ送信テスト</button>

  <script>
    console.log("開発環境がロードされました。");
    function testLog() {
      console.log("クリックされました: " + new Date().toLocaleTimeString());
    }
  </script>
</body>
</html></textarea>
              <div id="autocomplete-box"></div>
            </div>
          </div>

          <div class="preview-wrapper" id="preview-wrapper">
            <iframe id="html-preview" class="preview-frame" sandbox="allow-scripts allow-modals"></iframe>
          </div>
        </div>

        <div class="ide-terminal-panel" id="ide-terminal">
          <div class="ide-terminal-header">
            <span>Terminal (Linux penguin container)</span>
            <div style="display:flex; gap:6px;">
              <button class="win-btn" style="height:18px; width:18px; font-size:9px;" onclick="clearTerminal()">消去</button>
              <button class="win-btn" style="height:18px; width:18px; font-size:9px;" onclick="toggleTerminalHeight()">↕</button>
            </div>
          </div>
          <div id="term-out" class="terminal-output">Linux penguin 5.15.0-chromeos #1 SMP PREEMPT x86_64 GNU/Linux
システム準備完了。
</div>
          <div class="terminal-input-bar">
            <span class="terminal-prompt">user@penguin:~$</span>
            <input type="text" id="term-in" class="terminal-input" placeholder="コマンドを入力 (ls, uname, date, clear, help)" onkeydown="handleCmd(event)">
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- メモ帳 (Notepad) -->
  <div id="win-notepad" class="window" style="top:40px; left:60px; width:640px; height:460px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-notepad')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        メモ帳 - Notepad
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-notepad')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-notepad')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-notepad')">x</button>
      </div>
    </div>
    <div class="window-body">
      <div style="display:flex; gap:6px;">
        <button class="ide-btn" onclick="newNotepad()">新規</button>
        <button class="ide-btn" onclick="saveNotepad()">保存 (DL)</button>
        <span id="notepad-stats" style="font-size:11px; color:var(--text-muted); margin-left:auto; align-self:center;">文字数: 0</span>
      </div>
      <textarea id="notepad-text" class="notepad-textarea" placeholder="テキストを入力..." oninput="updateNotepadStats()"></textarea>
    </div>
  </div>

  <!-- ペイント (Paint) -->
  <div id="win-paint" class="window" style="top:60px; left:100px; width:700px; height:500px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-paint')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
        ペイント - Paint
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-paint')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-paint')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-paint')">x</button>
      </div>
    </div>
    <div class="window-body">
      <div class="paint-toolbar">
        <label style="font-size:11px; display:flex; align-items:center; gap:4px;">色: <input type="color" id="paint-color" value="#000000" style="background:transparent; border:none; width:24px; height:24px; cursor:pointer;"></label>
        <label style="font-size:11px; display:flex; align-items:center; gap:4px;">太さ: <input type="range" id="paint-size" min="1" max="40" value="4" style="width:70px;"></label>
        <button class="ide-btn" onclick="setPaintTool('brush')">ペン</button>
        <button class="ide-btn" onclick="setPaintTool('eraser')">消しゴム</button>
        <button class="ide-btn" onclick="clearPaint()">全消去</button>
        <button class="ide-btn ide-btn-primary" onclick="downloadPaint()">画像保存</button>
      </div>
      <canvas id="paint-canvas"></canvas>
    </div>
  </div>

  <!-- ファイルエクスプローラー -->
  <div id="win-explorer" class="window" style="top:70px; left:130px; width:640px; height:420px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-explorer')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
        エクスプローラー - Explorer
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-explorer')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-explorer')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-explorer')">x</button>
      </div>
    </div>
    <div class="window-body">
      <div class="explorer-container">
        <div class="explorer-sidebar">
          <div class="explorer-nav-item active">PC (C:)</div>
          <div class="explorer-nav-item">ドキュメント</div>
          <div class="explorer-nav-item">ダウンロード</div>
        </div>
        <div class="explorer-main">
          <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--cros-border); padding-bottom:6px;">
            <span style="font-size:11px; color:var(--text-muted);">場所: C:\Users\User\Documents</span>
            <button class="ide-btn" onclick="createNewFilePrompt()">新規作成</button>
          </div>
          <div id="file-list" style="display:flex; flex-direction:column; gap:6px; overflow-y:auto;"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- タスクマネージャー -->
  <div id="win-taskmgr" class="window" style="top:80px; left:160px; width:520px; height:380px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-taskmgr')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 12h3l2-5 3 10 2-5h2"/></svg>
        タスクマネージャー - Task Manager
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-taskmgr')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-taskmgr')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-taskmgr')">x</button>
      </div>
    </div>
    <div class="window-body">
      <div style="display:flex; gap:12px; font-size:11.5px; border-bottom:1px solid var(--cros-border); padding-bottom:8px;">
        <div>CPU使用率: <span id="tm-cpu" style="color:var(--yellow-primary); font-weight:bold;">12%</span></div>
        <div>メモリ使用率: <span id="tm-mem" style="color:var(--yellow-primary); font-weight:bold;">42%</span></div>
      </div>
      <div style="flex:1; overflow-y:auto;">
        <table class="taskmgr-table">
          <thead>
            <tr>
              <th>プロセス名</th>
              <th>状態</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody id="taskmgr-tbody"></tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- クロック・タイマー -->
  <div id="win-clock" class="window" style="top:90px; left:190px; width:360px; height:320px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-clock')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        クロック - Clock & Timer
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-clock')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-clock')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-clock')">x</button>
      </div>
    </div>
    <div class="window-body" style="align-items:center; justify-content:center;">
      <div id="stopwatch-display" class="clock-display">00:00.0</div>
      <div style="display:flex; gap:8px;">
        <button class="ide-btn ide-btn-primary" id="sw-btn" onclick="toggleStopwatch()">スタート</button>
        <button class="ide-btn" onclick="resetStopwatch()">リセット</button>
      </div>
    </div>
  </div>

  <!-- 付箋 -->
  <div id="win-sticky" class="window" style="top:110px; left:220px; width:280px; height:260px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-sticky')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><path d="M16 2H4a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8z"/></svg>
        付箋 - Sticky Note
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-sticky')">-</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-sticky')">x</button>
      </div>
    </div>
    <div class="window-body">
      <textarea id="sticky-text" class="sticky-note-area" placeholder="ここにメモを残せます..." oninput="saveSessionState()"></textarea>
    </div>
  </div>

  <!-- Web Browser -->
  <div id="win-browser" class="window" style="top:50px; left:60px; width:760px; height:500px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-browser')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
        Chrome Browser
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-browser')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-browser')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-browser')">x</button>
      </div>
    </div>
    <div class="window-body" style="background: #ffffff; padding: 10px; overflow-y: auto;">
      <script async src="https://cse.google.com/cse.js?cx=6673774b934ab4fae"></script>
      <div class="gcse-search"></div>
    </div>
  </div>

  <!-- 電卓 -->
  <div id="win-calc" class="window" style="top:80px; left:120px; width:280px; height:360px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-calc')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><rect x="4" y="2" width="16" height="20" rx="2"/></svg>
        電卓 - Calculator
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-calc')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-calc')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-calc')">x</button>
      </div>
    </div>
    <div class="window-body">
      <div class="calc-grid">
        <div id="calc-disp" class="calc-screen">0</div>
        <button class="calc-btn" onclick="calcInput('C')">C</button>
        <button class="calc-btn" onclick="calcInput('/')">/</button>
        <button class="calc-btn" onclick="calcInput('*')">*</button>
        <button class="calc-btn" onclick="calcInput('-')">-</button>
        <button class="calc-btn" onclick="calcInput('7')">7</button>
        <button class="calc-btn" onclick="calcInput('8')">8</button>
        <button class="calc-btn" onclick="calcInput('9')">9</button>
        <button class="calc-btn" onclick="calcInput('+')">+</button>
        <button class="calc-btn" onclick="calcInput('4')">4</button>
        <button class="calc-btn" onclick="calcInput('5')">5</button>
        <button class="calc-btn" onclick="calcInput('6')">6</button>
        <button class="calc-btn" style="grid-row: span 2; height:100%; background:var(--yellow-primary); color:#000; font-weight:bold;" onclick="calcInput('=')">=</button>
        <button class="calc-btn" onclick="calcInput('1')">1</button>
        <button class="calc-btn" onclick="calcInput('2')">2</button>
        <button class="calc-btn" onclick="calcInput('3')">3</button>
        <button class="calc-btn" style="grid-column: span 2;" onclick="calcInput('0')">0</button>
        <button class="calc-btn" onclick="calcInput('.')">.</button>
      </div>
    </div>
  </div>

  <!-- メディアプレイヤー -->
  <div id="win-media" class="window" style="top:110px; left:160px; width:340px; height:260px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-media')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg>
        メディアプレイヤー
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-media')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-media')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-media')">x</button>
      </div>
    </div>
    <div class="window-body" style="align-items:center; justify-content:center;">
      <input type="file" id="media-file" accept="audio/*,video/*" onchange="loadMedia(event)" style="font-size:11px; margin-bottom:12px; color:var(--text-muted);">
      <video id="media-player" controls style="width:100%; max-height:140px; background:#000; border-radius:6px; border:1px solid var(--cros-border);"></video>
    </div>
  </div>

  <!-- 設定 -->
  <div id="win-settings" class="window" style="top:140px; left:200px; width:300px; height:220px;">
    <div class="window-header" ondblclick="toggleMaximizeWindow('win-settings')">
      <div class="window-title">
        <svg viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        設定 - Settings
      </div>
      <div class="window-controls">
        <button class="win-btn" onclick="minimizeWindow('win-settings')">-</button>
        <button class="win-btn max-btn" onclick="toggleMaximizeWindow('win-settings')">[]</button>
        <button class="win-btn close-btn" onclick="closeWindow('win-settings')">x</button>
      </div>
    </div>
    <div class="window-body">
      <label style="font-size:12px; color:var(--text-muted);">背景トーンの変更:</label>
      <select id="theme-selector" onchange="changeTheme(this.value)" style="padding:6px; background:var(--cros-card-bg); color:var(--text-main); border:1px solid var(--cros-border); border-radius:6px; margin-top:8px; outline:none;">
        <option value="dark">マットブラック (標準)</option>
        <option value="charcoal">チャコールグレー</option>
      </select>
    </div>
  </div>

  <div id="toast-container"></div>

  <!-- Shelf（タスクバー） -->
  <div id="shelf">
    <div class="shelf-left">
      <button class="launcher-btn" onclick="toggleLauncher()" title="ランチャー">
        <div class="launcher-circle">
          <div class="launcher-circle-inner"></div>
        </div>
      </button>

      <div class="shelf-apps">
        <div class="shelf-app" id="shelf-win-studio" onclick="toggleAppWindow('win-studio')" title="Studio IDE">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
          <div class="shelf-indicator"></div>
        </div>
        <div class="shelf-app" id="shelf-win-notepad" onclick="toggleAppWindow('win-notepad')" title="メモ帳">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
          <div class="shelf-indicator"></div>
        </div>
        <div class="shelf-app" id="shelf-win-paint" onclick="toggleAppWindow('win-paint')" title="ペイント">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
          <div class="shelf-indicator"></div>
        </div>
        <div class="shelf-app" id="shelf-win-explorer" onclick="toggleAppWindow('win-explorer')" title="エクスプローラー">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
          <div class="shelf-indicator"></div>
        </div>
        <div class="shelf-app" id="shelf-win-browser" onclick="toggleAppWindow('win-browser')" title="ブラウザ">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
          <div class="shelf-indicator"></div>
        </div>
        <div class="shelf-app" id="shelf-win-calc" onclick="toggleAppWindow('win-calc')" title="電卓">
          <svg viewBox="0 0 24 24" fill="none" stroke="var(--yellow-primary)" stroke-width="2"><rect x="4" y="2" width="16" height="20" rx="2"/></svg>
          <div class="shelf-indicator"></div>
        </div>
      </div>
    </div>

    <div class="status-tray" onclick="toggleQuickSettings()" title="クイック設定">
      <span class="ime-badge">あ</span>
      <div class="status-icons">
        <svg id="tray-wifi-icon" viewBox="0 0 24 24"><path d="M5 12.55a11 11 0 0 1 14.08 0M1.42 9a16 16 0 0 1 21.16 0M8.53 16.11a6 6 0 0 1 6.95 0M12 20h.01"/></svg>
        <span id="tray-battery-text" style="font-size:11px; font-weight:bold;">100%</span>
      </div>
      <div id="shelf-clock">12:00</div>
    </div>
  </div>

  <script>
    /* =========================================================
       オーディオ & マスターボリューム制御
    ========================================================= */
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const masterGain = audioCtx.createGain();
    masterGain.connect(audioCtx.destination);
    masterGain.gain.value = 0.8;
    let realVolume = 0.8;

    function playSound(type) {
      if (audioCtx.state === 'suspended') audioCtx.resume();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.connect(gain); gain.connect(masterGain);

      if (type === 'boot') {
        osc.frequency.setValueAtTime(220, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(440, audioCtx.currentTime + 0.35);
        gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.35);
        osc.start(); osc.stop(audioCtx.currentTime + 0.35);
      } else if (type === 'click') {
        osc.frequency.setValueAtTime(400, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.03, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.03);
        osc.start(); osc.stop(audioCtx.currentTime + 0.03);
      }
    }

    function changeRealVolume(val) {
      realVolume = val / 100;
      masterGain.gain.setValueAtTime(realVolume, audioCtx.currentTime);
      const media = document.getElementById('media-player');
      if (media) media.volume = realVolume;
    }

    function changeRealBrightness(val) {
      const darkPercent = (100 - val) * 0.85;
      updateHardwareOverlay(darkPercent, isNightLightOn);
    }

    let isNightLightOn = false;
    function toggleNightLight() {
      playSound('click');
      isNightLightOn = !isNightLightOn;
      document.getElementById('tile-nightlight').classList.toggle('active', isNightLightOn);
      const brightVal = document.getElementById('real-bright-slider').value;
      updateHardwareOverlay((100 - brightVal) * 0.85, isNightLightOn);
      showToast(isNightLightOn ? '夜間モード ON' : '夜間モード OFF');
    }

    function updateHardwareOverlay(darkAlpha, nightLight) {
      const overlay = document.getElementById('hardware-filter-overlay');
      if (nightLight) {
        overlay.style.backgroundColor = 'rgba(255, 140, 0, 0.22)';
        overlay.style.backdropFilter = `brightness(${1 - darkAlpha/100}) sepia(35%)`;
      } else {
        overlay.style.backgroundColor = `rgba(0, 0, 0, ${darkAlpha / 100})`;
        overlay.style.backdropFilter = 'none';
      }
    }

    async function triggerRealBluetooth() {
      playSound('click');
      if (navigator.bluetooth) {
        try {
          showToast('Bluetooth検索中...');
          await navigator.bluetooth.requestDevice({ acceptAllDevices: true });
        } catch (e) {
          showToast('ペアリングがキャンセルされました');
        }
      } else {
        showToast('Web Bluetooth非対応環境です');
      }
    }

    function updateRealTime() {
      const now = new Date();
      document.getElementById('shelf-clock').innerText = 
        now.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});

      const days = ['日', '月', '火', '水', '木', '金', '土'];
      document.getElementById('qs-real-date').innerText = 
        `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日(${days[now.getDay()]})`;
    }
    setInterval(updateRealTime, 1000); updateRealTime();

    function updateRealNetwork() {
      const isOnline = navigator.onLine;
      const tile = document.getElementById('tile-network');
      const text = document.getElementById('tile-net-text');
      if (isOnline) {
        tile.classList.add('active');
        text.innerText = 'Wi-Fi (接続中)';
      } else {
        tile.classList.remove('active');
        text.innerText = '未接続 (オフライン)';
      }
    }
    window.addEventListener('online', updateRealNetwork);
    window.addEventListener('offline', updateRealNetwork);
    updateRealNetwork();

    function initRealBattery() {
      const batEl = document.getElementById('qs-real-battery');
      const trayBat = document.getElementById('tray-battery-text');

      if ('getBattery' in navigator) {
        navigator.getBattery().then(battery => {
          function renderBattery() {
            const level = Math.round(battery.level * 100);
            const isCharging = battery.charging;
            trayBat.innerText = isCharging ? `${level}% [充電中]` : `${level}%`;
            batEl.innerText = `バッテリー: ${level}% (${isCharging ? '電源に接続中 (充電中)' : 'バッテリー駆動'})`;
          }
          renderBattery();
          battery.addEventListener('levelchange', renderBattery);
          battery.addEventListener('chargingchange', renderBattery);
        });
      } else {
        batEl.innerText = 'バッテリー: 端末連携完了';
      }
    }
    initRealBattery();

    function showToast(msg) {
      const container = document.getElementById('toast-container');
      const toast = document.createElement('div');
      toast.className = 'toast';
      toast.innerText = msg;
      container.appendChild(toast);
      setTimeout(() => toast.remove(), 2500);
    }

    function toggleLauncher() {
      playSound('click');
      const l = document.getElementById('cros-launcher');
      const isOpen = l.style.display === 'flex';
      l.style.display = isOpen ? 'none' : 'flex';
      if (!isOpen) {
        document.getElementById('quick-settings-panel').style.display = 'none';
        document.getElementById('launcher-search').focus();
      }
    }

    function toggleQuickSettings() {
      playSound('click');
      const qs = document.getElementById('quick-settings-panel');
      const isOpen = qs.style.display === 'flex';
      qs.style.display = isOpen ? 'none' : 'flex';
      if (!isOpen) document.getElementById('cros-launcher').style.display = 'none';
    }

    document.getElementById('desktop').addEventListener('click', () => {
      document.getElementById('cros-launcher').style.display = 'none';
      document.getElementById('quick-settings-panel').style.display = 'none';
    });

    function filterLauncher(q) {
      document.querySelectorAll('.launcher-item').forEach(it => {
        it.style.display = it.innerText.toLowerCase().includes(q.toLowerCase()) ? 'flex' : 'none';
      });
    }

    /* =========================================================
       ウィンドウマネージャー & 復元システム
    ========================================================= */
    let zIndexCounter = 10;
    let isSessionLoaded = false;
    const ALL_WINDOWS = [
      'win-studio', 'win-notepad', 'win-paint', 'win-explorer', 'win-calc', 
      'win-browser', 'win-taskmgr', 'win-clock', 'win-sticky', 'win-media', 'win-settings'
    ];

    function getTopWindow() {
      let topWin = null, maxZ = -1;
      document.querySelectorAll('.window').forEach(win => {
        if (win.style.display === 'flex') {
          const z = parseInt(win.style.zIndex) || 0;
          if (z > maxZ) { maxZ = z; topWin = win; }
        }
      });
      return topWin;
    }

    function saveSessionState() {
      if (!isSessionLoaded) return;
      const winData = {};
      document.querySelectorAll('.window').forEach(win => {
        const isMax = win.classList.contains('maximized');
        const isSnapL = win.classList.contains('snap-left');
        const isSnapR = win.classList.contains('snap-right');
        winData[win.id] = {
          open: win.style.display === 'flex',
          maximized: isMax, snapLeft: isSnapL, snapRight: isSnapR,
          left: (isMax || isSnapL || isSnapR) ? (win.dataset.prevLeft || '40px') : (win.style.left || win.offsetLeft + 'px'),
          top: (isMax || isSnapL || isSnapR) ? (win.dataset.prevTop || '30px') : (win.style.top || win.offsetTop + 'px'),
          width: (isMax || isSnapL || isSnapR) ? (win.dataset.prevWidth || '780px') : (win.style.width || win.offsetWidth + 'px'),
          height: (isMax || isSnapL || isSnapR) ? (win.dataset.prevHeight || '520px') : (win.style.height || win.offsetHeight + 'px'),
          zIndex: parseInt(win.style.zIndex) || 10
        };
      });

      const session = {
        windows: winData,
        zIndexCounter: zIndexCounter,
        theme: document.getElementById('theme-selector').value,
        code: codeEditor.value,
        livePreview: document.getElementById('live-preview-toggle').checked,
        viewMode: document.getElementById('ide-view-mode').value,
        termLogs: document.getElementById('term-out').innerHTML,
        termVisible: document.getElementById('ide-terminal').style.display !== 'none',
        termHeight: document.getElementById('ide-terminal').style.height || '130px',
        calcExpr: calcExpr,
        calcDisp: document.getElementById('calc-disp').innerText,
        notepadText: document.getElementById('notepad-text').value,
        stickyText: document.getElementById('sticky-text').value,
        fileList: virtualFiles
      };

      try {
        localStorage.setItem('yellow_os_v_windows_fixed', JSON.stringify(session));
      } catch(e) {}
    }

    function loadSessionState() {
      const raw = localStorage.getItem('yellow_os_v_windows_fixed');
      if (raw) {
        try {
          const session = JSON.parse(raw);
          if (session.zIndexCounter) zIndexCounter = session.zIndexCounter;
          if (session.theme) {
            document.getElementById('theme-selector').value = session.theme;
            changeTheme(session.theme, false);
          }
          if (session.windows) {
            Object.keys(session.windows).forEach(winId => {
              const win = document.getElementById(winId);
              const data = session.windows[winId];
              if (win && data) {
                win.style.left = data.left; win.style.top = data.top;
                win.style.width = data.width; win.style.height = data.height;
                win.style.zIndex = data.zIndex;
                win.dataset.prevLeft = data.left; win.dataset.prevTop = data.top;
                win.dataset.prevWidth = data.width; win.dataset.prevHeight = data.height;

                win.classList.remove('maximized', 'snap-left', 'snap-right');
                const maxBtn = win.querySelector('.max-btn');
                if (data.maximized) { win.classList.add('maximized'); if (maxBtn) maxBtn.innerText = '❐'; }
                else if (data.snapLeft) win.classList.add('snap-left');
                else if (data.snapRight) win.classList.add('snap-right');

                win.style.display = data.open ? 'flex' : 'none';
              }
            });
          }
          
          // 破損したコード文字列が入っていた場合はリセット
          if (session.code !== undefined && !session.code.includes('class="hl-')) {
            codeEditor.value = session.code;
          }
          
          if (session.livePreview !== undefined) {
            document.getElementById('live-preview-toggle').checked = session.livePreview;
            livePreview = session.livePreview;
          }
          if (session.viewMode) {
            document.getElementById('ide-view-mode').value = session.viewMode;
            changeViewMode(session.viewMode, false);
          }
          if (session.termLogs) document.getElementById('term-out').innerHTML = session.termLogs;
          if (session.termHeight) document.getElementById('ide-terminal').style.height = session.termHeight;
          if (session.termVisible === false) document.getElementById('ide-terminal').style.display = 'none';

          if (session.calcExpr !== undefined) calcExpr = session.calcExpr;
          if (session.calcDisp !== undefined) document.getElementById('calc-disp').innerText = session.calcDisp;

          if (session.notepadText !== undefined) {
            document.getElementById('notepad-text').value = session.notepadText;
            updateNotepadStats();
          }
          if (session.stickyText !== undefined) document.getElementById('sticky-text').value = session.stickyText;
          if (session.fileList) virtualFiles = session.fileList;

        } catch(e) {}
      } else {
        openWindow('win-studio');
      }

      isSessionLoaded = true;
      renderFileList();
      updateShelfIcons();
      updateTaskmgrList();
      updateHighlight();
      renderHTML();
    }

    window.addEventListener('beforeunload', saveSessionState);

    /* キーボードショートカット */
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Meta') { e.preventDefault(); toggleLauncher(); return; }

      const activeWin = getTopWindow();
      if (e.altKey && (e.key === '[' || e.code === 'BracketLeft')) {
        e.preventDefault(); if (activeWin) snapWindow(activeWin.id, 'left'); return;
      }
      if (e.altKey && (e.key === ']' || e.code === 'BracketRight')) {
        e.preventDefault(); if (activeWin) snapWindow(activeWin.id, 'right'); return;
      }
      if (e.altKey && (e.key === '=' || e.code === 'Equal')) {
        e.preventDefault(); if (activeWin) toggleMaximizeWindow(activeWin.id); return;
      }
      if (e.altKey && (e.key === '-' || e.code === 'Minus')) {
        e.preventDefault(); if (activeWin) minimizeWindow(activeWin.id); return;
      }
      if (e.ctrlKey && (e.key === 'w' || e.key === 'W') && !e.shiftKey) {
        if (activeWin && document.activeElement.tagName !== 'TEXTAREA') {
          e.preventDefault(); closeWindow(activeWin.id); return;
        }
      }
      if (e.key === 'Escape') {
        document.getElementById('cros-launcher').style.display = 'none';
        document.getElementById('quick-settings-panel').style.display = 'none';
      }
    });

    function snapWindow(id, side) {
      playSound('click');
      const win = document.getElementById(id);
      savePrevBounds(win);
      win.classList.remove('maximized', 'snap-left', 'snap-right');
      win.classList.add(side === 'left' ? 'snap-left' : 'snap-right');
      win.style.zIndex = ++zIndexCounter;
      saveSessionState();
    }

    function savePrevBounds(win) {
      if (!win.classList.contains('maximized') && !win.classList.contains('snap-left') && !win.classList.contains('snap-right')) {
        win.dataset.prevLeft = win.style.left || win.offsetLeft + 'px';
        win.dataset.prevTop = win.style.top || win.offsetTop + 'px';
        win.dataset.prevWidth = win.style.width || win.offsetWidth + 'px';
        win.dataset.prevHeight = win.style.height || win.offsetHeight + 'px';
      }
    }

    function toggleAppWindow(id) {
      const win = document.getElementById(id);
      if (win.style.display === 'flex') {
        if (getTopWindow() === win) minimizeWindow(id);
        else { win.style.zIndex = ++zIndexCounter; saveSessionState(); }
      } else {
        openWindow(id);
      }
      updateShelfIcons();
    }

    function openWindow(id) {
      playSound('click');
      const win = document.getElementById(id);
      win.style.display = 'flex';
      win.style.zIndex = ++zIndexCounter;
      updateShelfIcons();
      updateTaskmgrList();
      saveSessionState();
      if (id === 'win-paint') resizePaintCanvas();
    }

    function closeWindow(id) {
      playSound('click');
      document.getElementById(id).style.display = 'none';
      updateShelfIcons();
      updateTaskmgrList();
      saveSessionState();
    }

    function minimizeWindow(id) {
      playSound('click');
      document.getElementById(id).style.display = 'none';
      updateShelfIcons();
      updateTaskmgrList();
      saveSessionState();
    }

    function toggleMaximizeWindow(id) {
      playSound('click');
      const win = document.getElementById(id);
      const btn = win.querySelector('.max-btn');
      
      if (win.classList.contains('maximized') || win.classList.contains('snap-left') || win.classList.contains('snap-right')) {
        win.classList.remove('maximized', 'snap-left', 'snap-right');
        win.style.left = win.dataset.prevLeft || '40px';
        win.style.top = win.dataset.prevTop || '30px';
        win.style.width = win.dataset.prevWidth || '780px';
        win.style.height = win.dataset.prevHeight || '520px';
        if (btn) btn.innerText = '[]';
      } else {
        savePrevBounds(win);
        win.classList.add('maximized');
        if (btn) btn.innerText = '❐';
      }
      win.style.zIndex = ++zIndexCounter;
      saveSessionState();
      if (id === 'win-paint') resizePaintCanvas();
    }

    function toggleOSFullscreen() {
      playSound('click');
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().then(() => showToast('全画面表示')).catch(() => {});
      } else {
        if (document.exitFullscreen) document.exitFullscreen();
      }
    }

    function updateShelfIcons() {
      const topWin = getTopWindow();
      ALL_WINDOWS.forEach(appId => {
        const win = document.getElementById(appId);
        const shelfBtn = document.getElementById('shelf-' + appId);
        if (shelfBtn && win) {
          if (win.style.display === 'flex') {
            shelfBtn.classList.add('open');
            shelfBtn.classList.toggle('active', topWin === win);
          } else {
            shelfBtn.classList.remove('open', 'active');
          }
        }
      });
    }

    /* ウィンドウドラッグ機能 */
    document.querySelectorAll('.window-header').forEach(header => {
      let isDragging = false, startX, startY, initialLeft, initialTop;
      const win = header.parentElement;

      const startDrag = (e) => {
        if (win.classList.contains('maximized') || win.classList.contains('snap-left') || win.classList.contains('snap-right')) return;
        isDragging = true;
        win.style.zIndex = ++zIndexCounter;
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        startX = clientX; startY = clientY;
        initialLeft = win.offsetLeft; initialTop = win.offsetTop;
        updateShelfIcons();
      };

      const doDrag = (e) => {
        if (!isDragging) return;
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        win.style.left = `${initialLeft + (clientX - startX)}px`;
        win.style.top = `${initialTop + (clientY - startY)}px`;
      };

      const stopDrag = () => { 
        if (isDragging) {
          isDragging = false;
          saveSessionState();
        }
      };

      header.addEventListener('mousedown', startDrag);
      document.addEventListener('mousemove', doDrag);
      document.addEventListener('mouseup', stopDrag);
      header.addEventListener('touchstart', startDrag, {passive:true});
      document.addEventListener('touchmove', doDrag, {passive:true});
      document.addEventListener('touchend', stopDrag);
    });

    /* Windows標準アプリ */
    function updateNotepadStats() {
      const text = document.getElementById('notepad-text').value;
      document.getElementById('notepad-stats').innerText = `文字数: ${text.length}`;
      saveSessionState();
    }
    function newNotepad() {
      if (confirm('メモをクリアしますか？')) {
        document.getElementById('notepad-text').value = '';
        updateNotepadStats();
      }
    }
    function saveNotepad() {
      const blob = new Blob([document.getElementById('notepad-text').value], { type: 'text/plain' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'memo.txt';
      a.click();
      showToast('メモを保存しました');
    }

    const paintCanvas = document.getElementById('paint-canvas');
    const paintCtx = paintCanvas.getContext('2d');
    let isPainting = false, paintTool = 'brush';

    function resizePaintCanvas() {
      paintCanvas.width = paintCanvas.parentElement.clientWidth - 16;
      paintCanvas.height = paintCanvas.parentElement.clientHeight - 60;
      paintCtx.fillStyle = '#ffffff';
      paintCtx.fillRect(0, 0, paintCanvas.width, paintCanvas.height);
    }
    function setPaintTool(t) { paintTool = t; }
    function clearPaint() {
      paintCtx.fillStyle = '#ffffff';
      paintCtx.fillRect(0, 0, paintCanvas.width, paintCanvas.height);
    }
    function downloadPaint() {
      const a = document.createElement('a');
      a.href = paintCanvas.toDataURL();
      a.download = 'drawing.png';
      a.click();
      showToast('イラストを保存しました');
    }

    function startPaint(e) { isPainting = true; drawPaint(e); }
    function endPaint() { isPainting = false; paintCtx.beginPath(); }
    function drawPaint(e) {
      if (!isPainting) return;
      const rect = paintCanvas.getBoundingClientRect();
      const x = (e.touches ? e.touches[0].clientX : e.clientX) - rect.left;
      const y = (e.touches ? e.touches[0].clientY : e.clientY) - rect.top;

      paintCtx.lineWidth = document.getElementById('paint-size').value;
      paintCtx.lineCap = 'round';
      paintCtx.strokeStyle = paintTool === 'eraser' ? '#ffffff' : document.getElementById('paint-color').value;

      paintCtx.lineTo(x, y);
      paintCtx.stroke();
      paintCtx.beginPath();
      paintCtx.moveTo(x, y);
    }

    paintCanvas.addEventListener('mousedown', startPaint);
    paintCanvas.addEventListener('mousemove', drawPaint);
    window.addEventListener('mouseup', endPaint);
    paintCanvas.addEventListener('touchstart', startPaint, {passive:true});
    paintCanvas.addEventListener('touchmove', drawPaint, {passive:true});
    window.addEventListener('touchend', endPaint);

    let virtualFiles = [
      { name: 'document.txt', content: 'これはサンプルのテキストファイルです。' },
      { name: 'todo.txt', content: 'やることリスト：シミュレーターの開発' }
    ];

    function renderFileList() {
      const container = document.getElementById('file-list');
      container.innerHTML = '';
      virtualFiles.forEach((file, index) => {
        const item = document.createElement('div');
        item.className = 'file-item';
        item.innerHTML = `
          <span>${file.name}</span>
          <div style="display:flex; gap:6px;">
            <button class="ide-btn" onclick="openFileInNotepad(${index})">開く</button>
            <button class="ide-btn" onclick="deleteVirtualFile(${index})">削除</button>
          </div>
        `;
        container.appendChild(item);
      });
    }

    function openFileInNotepad(idx) {
      document.getElementById('notepad-text').value = virtualFiles[idx].content;
      openWindow('win-notepad');
      updateNotepadStats();
    }

    function deleteVirtualFile(idx) {
      virtualFiles.splice(idx, 1);
      renderFileList();
      saveSessionState();
    }

    function createNewFilePrompt() {
      const name = prompt('ファイル名を入力してください (例: memo.txt):');
      if (name) {
        virtualFiles.push({ name: name, content: '' });
        renderFileList();
        saveSessionState();
      }
    }

    let swInterval = null, swElapsed = 0, swRunning = false;
    function toggleStopwatch() {
      const btn = document.getElementById('sw-btn');
      if (swRunning) {
        clearInterval(swInterval);
        swRunning = false;
        btn.innerText = 'スタート';
      } else {
        const start = Date.now() - swElapsed;
        swInterval = setInterval(() => {
          swElapsed = Date.now() - start;
          const min = Math.floor(swElapsed / 60000);
          const sec = Math.floor((swElapsed % 60000) / 1000);
          const ms = Math.floor((swElapsed % 1000) / 100);
          document.getElementById('stopwatch-display').innerText = 
            `${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}.${ms}`;
        }, 80);
        swRunning = true;
        btn.innerText = 'ストップ';
      }
    }
    function resetStopwatch() {
      clearInterval(swInterval);
      swElapsed = 0; swRunning = false;
      document.getElementById('sw-btn').innerText = 'スタート';
      document.getElementById('stopwatch-display').innerText = '00:00.0';
    }

    function updateTaskmgrList() {
      const tbody = document.getElementById('taskmgr-tbody');
      tbody.innerHTML = '';
      ALL_WINDOWS.forEach(id => {
        const win = document.getElementById(id);
        if (win && win.style.display === 'flex') {
          const title = win.querySelector('.window-title').innerText.trim();
          const tr = document.createElement('tr');
          tr.innerHTML = `
            <td>${title}</td>
            <td style="color:#4ade80;">実行中</td>
            <td><button class="ide-btn" style="background:#dc2626; color:#fff;" onclick="closeWindow('${id}')">終了</button></td>
          `;
          tbody.appendChild(tr);
        }
      });
    }

    setInterval(() => {
      document.getElementById('tm-cpu').innerText = `${Math.floor(8 + Math.random() * 15)}%`;
      document.getElementById('tm-mem').innerText = `${Math.floor(38 + Math.random() * 8)}%`;
    }, 2000);

    /* =========================================================
       🌟 堅牢な単一パストークナイザー（自己破壊バグ完全根絶）
    ========================================================= */
    const codeEditor = document.getElementById('html-code');
    const autoBox = document.getElementById('autocomplete-box');
    let livePreview = false, liveTimer = null;

    // 1回の正規表現走査で分解するため、spanタグが自己増殖しない！
    function highlightSyntax(text) {
      const escaped = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      
      const tokenRegex = /(&lt;!--[\s\S]*?--&gt;|\/\/[^\n]*|\/\*[\s\S]*?\*\/)|(".*?"|'.*?'|`[\s\S]*?`)|(&lt;\/?[a-zA-Z0-9\-!]+)|([a-zA-Z0-9\-:]+)(?=\=)|(&gt;|&lt;|\/)|(\b(?:function|return|let|const|var|new|if|else|for|while|class|import|export)\b)|(\b(?:console|document|window|Date|Math|true|false|null|undefined)\b)/g;

      return escaped.replace(tokenRegex, (match, comment, str, tag, attr, bracket, keyword, builtin) => {
        if (comment) return `<span class="hl-comment">${comment}</span>`;
        if (str) return `<span class="hl-str">${str}</span>`;
        if (tag) {
          const isClose = tag.startsWith('&lt;/');
          const prefix = isClose ? '&lt;/' : '&lt;';
          const name = tag.slice(prefix.length);
          return `<span class="hl-bracket">${prefix}</span><span class="hl-tagname">${name}</span>`;
        }
        if (attr) return `<span class="hl-attr">${attr}</span>`;
        if (bracket) return `<span class="hl-bracket">${bracket}</span>`;
        if (keyword) return `<span class="hl-keyword">${keyword}</span>`;
        if (builtin) return `<span class="hl-builtin">${builtin}</span>`;
        return match;
      }) + '\n';
    }

    function updateHighlight() {
      const code = codeEditor.value;
      document.getElementById('highlighting-content').innerHTML = highlightSyntax(code);
    }

    function syncEditorScroll() {
      const pre = document.getElementById('highlighting');
      pre.scrollTop = codeEditor.scrollTop;
      pre.scrollLeft = codeEditor.scrollLeft;
    }

    const SNIPPETS = [
      { trigger: 'div', insert: '<div>$0</div>', type: 'tag' },
      { trigger: 'span', insert: '<span>$0</span>', type: 'tag' },
      { trigger: 'button', insert: '<button onclick="$0">ボタン</button>', type: 'tag' },
      { trigger: 'input', insert: '<input type="text" placeholder="$0">', type: 'tag' },
      { trigger: 'script', insert: '<script>\n  $0\n<\/script>', type: 'tag' },
      { trigger: 'style', insert: '<style>\n  $0\n</style>', type: 'tag' },
      { trigger: 'canvas', insert: '<canvas id="$0" width="300" height="200"></canvas>', type: 'tag' },
      { trigger: 'clog', insert: 'console.log($0);', type: 'js' },
      { trigger: 'func', insert: 'function $0() {\n  \n}', type: 'js' }
    ];

    let currentSuggestions = [], selectedSuggestIndex = 0;

    function handleEditorInput() {
      updateHighlight();
      saveSessionState();
      if (livePreview) {
        clearTimeout(liveTimer);
        liveTimer = setTimeout(renderHTML, 400);
      }
      checkAutocomplete();
    }

    function checkAutocomplete() {
      const pos = codeEditor.selectionStart;
      const text = codeEditor.value.slice(0, pos);
      const match = text.match(/([a-zA-Z0-9_-]+|<[a-zA-Z0-9_-]*)$/);

      if (match && match[0].length >= 2) {
        const query = match[0].replace('<', '').toLowerCase();
        currentSuggestions = SNIPPETS.filter(s => s.trigger.toLowerCase().startsWith(query));
        if (currentSuggestions.length > 0) {
          showAutocompleteBox(currentSuggestions);
          return;
        }
      }
      hideAutocompleteBox();
    }

    function showAutocompleteBox(list) {
      autoBox.innerHTML = '';
      selectedSuggestIndex = 0;
      list.forEach((item, idx) => {
        const div = document.createElement('div');
        div.className = `suggest-item ${idx === 0 ? 'active' : ''}`;
        div.innerHTML = `<span>${item.trigger}</span><span class="suggest-type">${item.type}</span>`;
        div.onmousedown = (e) => { e.preventDefault(); applySuggestion(item); };
        autoBox.appendChild(div);
      });
      autoBox.style.display = 'flex';
      autoBox.style.left = '30px'; autoBox.style.top = '30px';
    }

    function hideAutocompleteBox() {
      autoBox.style.display = 'none';
      currentSuggestions = [];
    }

    function applySuggestion(item) {
      const pos = codeEditor.selectionStart;
      const text = codeEditor.value;
      const match = text.slice(0, pos).match(/([a-zA-Z0-9_-]+|<[a-zA-Z0-9_-]*)$/);
      const replaceLen = match ? match[0].length : 0;
      const insertText = item.insert.replace('$0', '');
      codeEditor.value = text.slice(0, pos - replaceLen) + insertText + text.slice(pos);
      const newPos = pos - replaceLen + insertText.length;
      codeEditor.setSelectionRange(newPos, newPos);
      hideAutocompleteBox();
      codeEditor.focus();
      updateHighlight();
      saveSessionState();
      if (livePreview) renderHTML();
    }

    function handleEditorKeyDown(e) {
      if (autoBox.style.display === 'flex') {
        if (e.key === 'ArrowDown') {
          e.preventDefault();
          selectedSuggestIndex = (selectedSuggestIndex + 1) % currentSuggestions.length;
          updateSuggestActive(); return;
        } else if (e.key === 'ArrowUp') {
          e.preventDefault();
          selectedSuggestIndex = (selectedSuggestIndex - 1 + currentSuggestions.length) % currentSuggestions.length;
          updateSuggestActive(); return;
        } else if (e.key === 'Enter' || e.key === 'Tab') {
          e.preventDefault();
          applySuggestion(currentSuggestions[selectedSuggestIndex]); return;
        } else if (e.key === 'Escape') {
          hideAutocompleteBox(); return;
        }
      }
      if (e.key === 'Tab') {
        e.preventDefault();
        const start = codeEditor.selectionStart, end = codeEditor.selectionEnd;
        codeEditor.value = codeEditor.value.substring(0, start) + '  ' + codeEditor.value.substring(end);
        codeEditor.selectionStart = codeEditor.selectionEnd = start + 2;
        updateHighlight();
        saveSessionState();
      }
    }

    function updateSuggestActive() {
      const items = autoBox.querySelectorAll('.suggest-item');
      items.forEach((it, idx) => it.classList.toggle('active', idx === selectedSuggestIndex));
    }

    function renderHTML() {
      playSound('click');
      const code = codeEditor.value;
      const preview = document.getElementById('html-preview');
      const injectedCode = `
        <script>
          (function(){
            const oldLog = console.log;
            console.log = function(...args) {
              window.parent.postMessage({ type: 'console', level: 'log', data: args.join(' ') }, '*');
              oldLog.apply(console, args);
            };
            const oldErr = console.error;
            console.error = function(...args) {
              window.parent.postMessage({ type: 'console', level: 'error', data: args.join(' ') }, '*');
              oldErr.apply(console, args);
            };
            window.onerror = function(msg, url, line) {
              window.parent.postMessage({ type: 'console', level: 'error', data: msg + ' (line ' + line + ')' }, '*');
            };
          })();
        <\/script>
      ` + code;
      const blob = new Blob([injectedCode], { type: 'text/html;charset=utf-8' });
      preview.src = URL.createObjectURL(blob);
    }

    window.addEventListener('message', (e) => {
      if (e.data && e.data.type === 'console') {
        const out = document.getElementById('term-out');
        const levelClass = e.data.level === 'error' ? 'terminal-log-error' : '';
        out.innerHTML += `<div class="${levelClass}">[${e.data.level.toUpperCase()}] ${e.data.data}</div>`;
        out.scrollTop = out.scrollHeight;
        saveSessionState();
      }
    });

    function toggleLiveMode() {
      livePreview = document.getElementById('live-preview-toggle').checked;
      showToast(livePreview ? 'Live更新 ON' : 'Live更新 OFF');
      saveSessionState();
      if (livePreview) renderHTML();
    }

    function changeViewMode(mode, save = true) {
      const ed = document.getElementById('editor-wrapper');
      const pr = document.getElementById('preview-wrapper');
      if (mode === 'code') { ed.style.display = 'flex'; pr.style.display = 'none'; }
      else if (mode === 'preview') { ed.style.display = 'none'; pr.style.display = 'flex'; }
      else { ed.style.display = 'flex'; pr.style.display = 'flex'; }
      if (save) saveSessionState();
    }

    function toggleTerminalPanel() {
      const p = document.getElementById('ide-terminal');
      p.style.display = (p.style.display === 'none') ? 'flex' : 'none';
      saveSessionState();
    }

    function toggleTerminalHeight() {
      const p = document.getElementById('ide-terminal');
      p.style.height = (p.style.height === '240px') ? '130px' : '240px';
      saveSessionState();
    }

    function clearTerminal() {
      document.getElementById('term-out').innerText = '';
      saveSessionState();
    }

    function downloadCode() {
      const blob = new Blob([codeEditor.value], { type: 'text/html' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'app.html';
      a.click();
      showToast('ファイルをダウンロードしました');
    }

    function uploadCode(e) {
      const file = e.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (event) => {
          codeEditor.value = event.target.result;
          updateHighlight();
          renderHTML();
          saveSessionState();
          showToast('ファイルを読み込みました');
        };
        reader.readAsText(file);
      }
    }

    function loadTemplate(key) {
      if (!key) return;
      if (key === 'counter') {
        codeEditor.value = `<!DOCTYPE html>
<html>
<head>
  <style>
    body { background: #121212; color: #fff; font-family: sans-serif; text-align: center; padding-top: 40px; }
    #count { font-size: 48px; color: #eab308; margin: 16px 0; }
    button { padding: 10px 20px; font-size: 16px; border-radius: 6px; border: none; cursor: pointer; background: #eab308; font-weight: bold; }
  </style>
</head>
<body>
  <h2>カウンター</h2>
  <div id="count">0</div>
  <button onclick="inc()">+1 カウント</button>
  <script>
    let n = 0;
    function inc() {
      n++;
      document.getElementById('count').innerText = n;
      console.log('カウント: ' + n);
    }
  <\/script>
</body>
</html>`;
      } else if (key === 'game') {
        codeEditor.value = `<!DOCTYPE html>
<html>
<head>
  <style>
    body { margin: 0; background: #000; overflow: hidden; display: flex; justify-content: center; align-items: center; height: 100vh; }
    canvas { border: 1px solid #eab308; }
  </style>
</head>
<body>
  <canvas id="c" width="300" height="200"></canvas>
  <script>
    const cvs = document.getElementById('c'), ctx = cvs.getContext('2d');
    let x = 50, y = 50, dx = 3, dy = 3, r = 10;
    function loop() {
      ctx.fillStyle = 'rgba(0,0,0,0.2)';
      ctx.fillRect(0,0,cvs.width,cvs.height);
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI*2);
      ctx.fillStyle = '#eab308';
      ctx.fill();
      if(x + dx > cvs.width - r || x + dx < r) dx = -dx;
      if(y + dy > cvs.height - r || y + dy < r) dy = -dy;
      x += dx; y += dy;
      requestAnimationFrame(loop);
    }
    loop();
  <\/script>
</body>
</html>`;
      } else if (key === 'ui') {
        codeEditor.value = `<!DOCTYPE html>
<html>
<head>
  <style>
    body { background: #121212; color: #fff; font-family: sans-serif; padding: 20px; }
    .card { background: #1e1e1e; border: 1px solid #3f3f46; border-radius: 8px; padding: 16px; border-left: 4px solid #eab308; }
    .title { color: #eab308; font-weight: bold; margin-bottom: 8px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="title">Yellow OS スタイルカード</div>
    <p>ダーク＆マットイエローのUIパーツです。</p>
  </div>
</body>
</html>`;
      }
      updateHighlight();
      renderHTML();
      saveSessionState();
      showToast('テンプレートを展開しました');
    }

    function handleCmd(e) {
      if (e.key === 'Enter') {
        playSound('click');
        const input = document.getElementById('term-in');
        const out = document.getElementById('term-out');
        const cmd = input.value.trim();
        out.innerHTML += `<div><span style="color:#38bdf8">user@penguin:~$</span> ${cmd}</div>`;
        
        if (cmd === 'clear') out.innerHTML = '';
        else if (cmd === 'ls') out.innerHTML += `<div>index.html  app.js  style.css  Downloads/</div>`;
        else if (cmd === 'pwd') out.innerHTML += `<div>/home/user</div>`;
        else if (cmd === 'whoami') out.innerHTML += `<div>user</div>`;
        else if (cmd === 'uname' || cmd === 'uname -a') out.innerHTML += `<div>Linux penguin 5.15.0-chromeos #1 SMP PREEMPT x86_64 GNU/Linux</div>`;
        else if (cmd === 'date') out.innerHTML += `<div>${new Date().toString()}</div>`;
        else if (cmd === 'help') out.innerHTML += `<div>Linux commands: ls, pwd, whoami, uname, date, clear, echo, run, help</div>`;
        else if (cmd.startsWith('echo ')) out.innerHTML += `<div>${cmd.substring(5)}</div>`;
        else if (cmd === 'run') { renderHTML(); out.innerHTML += `<div>HTMLを描画実行しました。</div>`; }
        else if (cmd !== '') out.innerHTML += `<div class="terminal-log-error">bash: ${cmd}: コマンドが見つかりません</div>`;
        
        input.value = '';
        out.scrollTop = out.scrollHeight;
        saveSessionState();
      }
    }

    function changeTheme(theme, save = true) {
      if (save) playSound('click');
      document.getElementById('desktop').style.background = (theme === 'charcoal') ? '#1f242d' : '#121212';
      if (save) saveSessionState();
    }

    let calcExpr = '';
    function calcInput(val) {
      playSound('click');
      const disp = document.getElementById('calc-disp');
      if (val === 'C') { calcExpr = ''; disp.innerText = '0'; }
      else if (val === '=') {
        try { calcExpr = eval(calcExpr).toString(); disp.innerText = calcExpr; }
        catch { disp.innerText = 'Error'; calcExpr = ''; }
      } else {
        calcExpr += val; disp.innerText = calcExpr;
      }
      saveSessionState();
    }

    function loadMedia(e) {
      const file = e.target.files[0];
      if (file) {
        document.getElementById('media-player').src = URL.createObjectURL(file);
        document.getElementById('media-player').volume = realVolume;
        document.getElementById('media-player').play();
        showToast('再生開始');
      }
    }

    window.addEventListener('load', () => {
      playSound('boot');
      loadSessionState();
      setTimeout(() => {
        const bootScreen = document.getElementById('boot-screen');
        bootScreen.style.opacity = '0';
        bootScreen.style.visibility = 'hidden';
      }, 1200);
    });
  </script>
</body>
</html>
