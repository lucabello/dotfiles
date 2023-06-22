{-# OPTIONS_GHC -Wno-missing-signatures #-}

module Custom.MyLayouts where

import Custom.MyDecorations
import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Accordion
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.BoringWindows
import XMonad.Layout.Column
import XMonad.Layout.MultiColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.PerScreen
import XMonad.Layout.Renamed as XLR
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation

mySpacing i = spacingRaw False (Border 10 10 30 30) True (Border i i i i) True

tall =
  renamed [XLR.Replace "Tall"] $
    avoidStruts $
      windowNavigation $
        mySpacing 7 $
          ResizableTall nmaster delta ratio []
  where
    nmaster = 1
    ratio = 1 / 2
    delta = 3 / 100

column =
  renamed [XLR.Replace "Column"] $
    avoidStruts $
      windowNavigation $
        mySpacing 7 $
          Column 1.0

multicolumns =
  renamed [XLR.Replace "MultiColumns"] $
    avoidStruts $
      windowNavigation $
        mySpacing 7 $
          multiCol [1] 1 0.01 (-0.5)

accordion =
  renamed [XLR.Replace "Accordion"] $
    avoidStruts $
      windowNavigation $
        mySpacing 7 Accordion

full = renamed [XLR.Replace "Full"] $ noBorders Full

sf = renamed [XLR.Replace "Float"] $ noBorders simplestFloat

myLayout = boringWindows (ifWider 1440 (tall ||| multicolumns) (column ||| accordion) ||| full)

myLayoutHook = myLayout