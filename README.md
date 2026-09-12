# SMTC Bridge OBS Proxy

A small companion tool for [SMTC Bridge](https://github.com/nuttylmao/smtc-bridge) that fixes one specific scenario: using the [Universal Now Playing Widget](https://widgets.nutty.gg) by nutty.gg **in OBS, on a dual-PC streaming setup**, where OBS runs on a different machine than the one actually playing music.

> Unofficial community fix — not affiliated with SMTC Bridge, nutty.gg, or their teams.

## The problem — and what this is *not* fixing

**The Universal Now Playing Widget itself isn't broken.** It works exactly as intended for the vast majority of setups — single-PC streaming, or viewing it directly in a browser.

The issue only shows up in one specific case: a **dual-PC setup**, where the widget needs to run inside **OBS's Browser Source on PC B**, pulling song data from **SMTC Bridge running on PC A** over your local network or a tool like Tailscale.

Here's why that specific combination breaks: the widget page is served from `https://widgets.nutty.gg`, but it needs to fetch your song data from SMTC Bridge over plain `http://`. Browsers block that combination ("mixed content"), and OBS's Browser Source has no way to grant an exception the way a normal browser tab can. The result: the widget just hangs on **"Waiting for SMTC Bridge"** forever inside OBS specifically — even though the exact same link works perfectly fine opened directly in a regular browser, and even though SMTC Bridge itself is running and reachable.

## The fix

SMTC Bridge is a tool by nuttylmao, publicly available on GitHub, that this proxy sits on top of to actually read what's playing on your PC. (Note: its GitHub repo doesn't currently include a license file, so it's source-visible rather than formally "open source" — worth keeping in mind if you plan to build on it further.) This repo is a small Python proxy I wrote on top of it, specifically to make that remote, dual-PC connection work reliably through OBS.

It runs a tiny local proxy that mirrors the widget's own page over plain `http://` instead of `https://`. Once the widget page itself loads over `http://`, it can talk to your local SMTC Bridge without any scheme mismatch — nothing left for OBS to block.

## Setup

You'll need SMTC Bridge already installed and working first — see its [repo](https://github.com/nuttylmao/smtc-bridge) if you haven't set that up yet.

**Important:** by default, SMTC Bridge only listens on `127.0.0.1` (your own PC). For a dual-PC setup, open SMTC Bridge's `settings.ini` and change the host from `127.0.0.1` to `0.0.0.0`, then restart SMTC Bridge. This lets it accept connections from your other PC in the first place — without this change, nothing in this repo will help, since SMTC Bridge won't be reachable remotely at all.

### Option A: Just run the .exe (recommended, no Python needed)

1. Download the latest release from the [Releases page](../../releases).
2. Unzip it next to your `smtc-bridge.exe`.
3. Run `SMTC-Widget-Proxy.exe`. It runs silently in the background — no window will appear.
4. (Optional) To have both apps start automatically at login, run `start-smtc-and-proxy.vbs` once, or copy it into your Windows Startup folder (`Win+R` → `shell:startup`).

### Option B: Run from source

```
pip install flask requests waitress
python bridge_widget_proxy.py
```

## Using it in OBS

Take your usual widget URL and:
- Change the domain from `https://widgets.nutty.gg` to `http://<your-PC-IP>:8000`
- Keep `smtcBridgeAddress` and `smtcBridgePort` pointed at your actual SMTC Bridge as normal

Example:

```
http://192.168.1.50:8000/now-playing/?theme=standard&smtcBridgeAddress=192.168.1.50&smtcBridgePort=5000
```

Use your Tailscale IP instead of a LAN IP if you're viewing the widget from a different network (e.g. a second PC that isn't on the same Wi-Fi/router).

## Notes

- This proxy mirrors nutty's widget assets live at runtime — it doesn't copy or redistribute them. If nutty changes their site structure, this may need an update.
- Logs are written to `bridge_widget_proxy.log`, next to wherever the exe/script is running, if you need to troubleshoot.

## Credit

- [SMTC Bridge](https://github.com/nuttylmao/smtc-bridge) — a tool by nuttylmao that this proxy sits on top of. It's publicly available on GitHub; note its repo doesn't currently include a license file.
- [Universal Now Playing Widget](https://widgets.nutty.gg) by nutty.gg — the widget this proxy is making dual-PC/OBS compatible. Again, the widget itself works great; this only addresses the specific remote dual-PC scenario described above.
