{-# LANGUAGE ImportQualifiedPost #-}

module Custom.MyKeys where

import Custom.MyDecorations
-- import Custom.MyMacAddresses
import Custom.MyWorkspaces
import Data.Map qualified as M
import System.Exit
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.EasyMotion
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Search qualified as S
import XMonad.Actions.Submap qualified as SM
import XMonad.Actions.WithAll
import XMonad.Hooks.ManageDocks
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.BoringWindows
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation as WN
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.Man
import XMonad.Prompt.XMonad
import XMonad.StackSet qualified as W


cmd_nightmode = "if pgrep redshift; then pkill redshift; else redshift -l 48.137154:11.576124 -t 6500:4000; fi"

myKeys :: [(String, X ())]
myKeys =
  [ -- Terminal
    ("M-<Return>", spawn "alacritty"),
    -- Browser
    ("M-w", spawn "brave || brave-browser"),
    ("M-S-w", spawn "brave --incognito || brave-browser --incognito"),
    -- Rofi
    ("M-b", spawn "~/.config/rofi/scripts/bukumenu.sh"),
    ("C-.", spawn "rofimoji --skin-tone=light"),
    ("M-C-p", spawn "~/.config/rofi/scripts/powermenu.sh"),
    -- ("M-p", spawn "~/.config/rofi/themes/randomiser.sh; rofi -show drun"),
    -- ("M-y", spawn "~/.config/rofi/themes/randomiser.sh; rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'"),
    -- ("M1-<Tab>", spawn "rofi -show window"),
    ("C-<Space>", spawn " ~/.config/rofi/scripts/launcher.sh"),
    -- Utilities
    ("M-n", spawn cmd_nightmode),
    ("M-f", spawn "alacritty -e ranger"),
    ("M-S-t", spawn "~/.scripts/open-term-at-dir"),
    -- -- XPrompts
    -- ("M-r", manPrompt myPromptConfig),
    -- ("M-r", xmonadPrompt myPromptConfig),
    ("M-r", confirmPrompt myPromptConfig "exit" $ io exitSuccess),
    -- Flameshot
    ("<Print>", spawn "flameshot gui"),
    ("S-<Print>", spawn "flameshot full"),
    -- Bluetooth
    {- ("<Page_Up>", spawn ("bluetoothctl connect " ++ mySpeakerMac)),
    ("<Home>", spawn ("bluetoothctl connect " ++ myXMMac)),
    ("<Page_Down>", spawn "bluetoothctl disconnect"), -}
    -- Close window(s)
    ("M-c", kill),
    ("M-S-c", killAll),
    ("M-<Escape>", spawn "xkill"),
    -- Layouts
    ("M-<Space>", sendMessage NextLayout),
    ("M-C-<Space>", spawn "polybar-msg cmd toggle" >> sendMessage ToggleStruts),
    ("M-C-b", sendMessage $ Toggle NOBORDERS),
    -- ("M-f", sendMessage $ JumpToLayout "Full"),
    -- Cycle workspaces
    -- ("M-<Down>", nextWS),
    -- ("M-<Up>", prevWS),
    ("M-S-<Down>", shiftToNext),
    ("M-S-<Up>", shiftToPrev),
    ("M-<Right>", nextScreen),
    ("M-<Left>", prevScreen),
    ("M-S-<Right>", shiftNextScreen),
    ("M-S-<Left>", shiftPrevScreen),
    ("M-S-z", toggleWS),
    ("M-S-<Down>", shiftToNext >> nextWS),
    ("M-S-<Up>", shiftToPrev >> prevWS),
    -- Focus
    ("M-<Tab>", windows W.focusDown),
    ("M-S-<Tab>", windows W.focusUp),
    ("M-k", focusUp),
    ("M-j", focusDown),
    ("M-m", focusMaster),
    ("M-S-<Return>", windows W.swapMaster),
    ("M-S-j", swapDown),
    ("M-S-k", swapUp),
    -- Resize
    ("M-h", sendMessage Shrink),
    ("M-l", sendMessage Expand),
    ("M-C-j", sendMessage MirrorShrink),
    ("M-C-k", sendMessage MirrorExpand),
    ("M-t", withFocused $ windows . W.sink),
    ("M-,", sendMessage (IncMasterN 1)),
    ("M-.", sendMessage (IncMasterN (-1))),
    -- XMonad
    ("M-q", spawn "xmonad --recompile && xmonad --restart"),
    -- Volume
    ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -1%"),
    ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1%"),
    ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle"),
    -- Spacing
    ("M-C-S-k", incScreenSpacing 5),
    ("M-C-S-j", decScreenSpacing 5),
    ("M-C-S-l", incWindowSpacing 5),
    ("M-C-S-h", decWindowSpacing 5),
    -- Easy Motion
    ("M-g", selectWindow emConf >>= (`whenJust` windows . W.focusWindow)),
    ("M-x", selectWindow emConf >>= (`whenJust` killWindow))
  ]

myAdditionalKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    -- Reset the layouts on the current workspace to default
    [((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)]
      ++ [ ((m .|. mod1Mask, k), windows $ f i)
           | (i, k) <- zip myWorkspaces [xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_0],
             (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
         ]
      ++ [ ((mod1Mask .|. mask, key), f sc)
           | (key, sc) <- zip [xK_d, xK_a, xK_s] [0 ..],
             (f, mask) <- [(viewScreen def, 0), (sendToScreen def, shiftMask)]
         ]
