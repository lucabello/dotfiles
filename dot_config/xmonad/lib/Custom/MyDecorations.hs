module Custom.MyDecorations where

import Custom.MyTheme
import XMonad (xK_Escape)
import XMonad qualified
import XMonad.Actions.EasyMotion
import XMonad.Layout.ShowWName
import XMonad.Layout.Tabbed
import XMonad.Prompt

myBorderWidth :: XMonad.Dimension
myBorderWidth = 4

myNormalBorderColor :: String
myNormalBorderColor = themeBackground

myFocusedBorderColor :: String
myFocusedBorderColor = themeAccent

myPromptConfig :: XPConfig
myPromptConfig =
  def
    { bgColor = themeBackground,
      fgColor = themeAccentSecondary,
      bgHLight = themeAccentSecondary,
      fgHLight = themeBackground,
      historySize = 0,
      position = Top,
      borderColor = themeBackground,
      promptBorderWidth = 0,
      defaultText = "",
      alwaysHighlight = True,
      height = 55,
      font = "xft:Vanilla Caramel:style=Regular:size=12",
      autoComplete = Nothing,
      showCompletionOnTab = False
    }

-- myShowWNameConfig :: SWNConfig
-- myShowWNameConfig =
--   def
--     { swn_font = "xft:Vanilla Caramel:size=60",
--       swn_color = catLavender,
--       swn_bgcolor = catBase,
--       swn_fade = 0.8
--     }

-- myTabConfig :: Theme
-- myTabConfig =
--   def
--     { activeColor = catLavender,
--       inactiveColor = catBase,
--       urgentColor = catRed,
--       activeBorderColor = catBase,
--       inactiveBorderColor = catBase,
--       urgentBorderColor = catRed,
--       activeTextColor = catBase,
--       inactiveTextColor = catFlamingo,
--       urgentTextColor = catBase,
--       fontName = "xft:Vanilla Caramel:size=12"
--     }

emConf :: EasyMotionConfig
emConf =
  def
    { txtCol = themeAccentSecondary,
      bgCol = themeBorder,
      borderCol = themeBorder,
      cancelKey = xK_Escape,
      emFont = "xft: Vanilla Caramel-60",
      overlayF = textSize,
      borderPx = 30
    }
