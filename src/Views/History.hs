{-# LANGUAGE OverloadedStrings #-}

module Views.History where
  
  
import            Text.Templating.Heist
import qualified  Data.Text.Encoding as TE
import qualified  Data.Text as T
import qualified  Text.XmlHtml as X
import qualified  Data.Map as M
import            Data.List (intercalate)
import            Data.Time.Clock
import            Data.Time.LocalTime
import            Data.Time.Format
import            System.Locale
import            Control.Monad.Trans (liftIO)


import            Data.Maybe (fromMaybe, maybeToList)
import qualified  Data.ByteString.Char8 as B8
import qualified  Data.ByteString as BS
import            Snap.Extension.DB.MongoDB (bs2objid, objid2bs)

import            Application

import            Models.History
import            Models.Person

import            Views.Site

renderHistoryChild :: (UTCTime -> LocalTime) -> [Person] -> History -> Splice Application
renderHistoryChild t people h = runChildrenWith (renderHistoryEntry t people h)

renderHistoryEntry :: (UTCTime -> LocalTime) -> [Person] -> History -> [(T.Text, Splice Application)]
renderHistoryEntry t people (Add uid htid date who what category when howmuch whopays) =
  (renderuhd t uid htid date) ++ (renderadddel people who what category when howmuch whopays) ++ [("type", textSplice "Add")]
renderHistoryEntry t people (Delete uid htid date who what category when howmuch whopays) =
  (renderuhd t uid htid date) ++ (renderadddel people who what category when howmuch whopays) ++ [("type", textSplice "Delete")]
renderHistoryEntry t people (Edit uid htid date who what category when howmuch whopays) =
  (renderuhd t uid htid date) ++ 
  (renderChangeT "who" (TE.decodeUtf8 . objid2bs) who) ++
  (renderChangeT "what" TE.decodeUtf8 what) ++
  (renderChangeT "category" TE.decodeUtf8 category) ++
  (renderChangeT "when" (T.pack . show) when) ++
  (renderChangeT "ammount" (T.pack . moneyShow) howmuch) ++
  (renderChangeT "forSummary" (T.pack . showPeople people) whopays) ++
  (renderChange  "for" forSplice whopays) ++ 
  [("type", textSplice "Edit")]


renderuhd t uid htid date = map ((\(a,b) -> (a, textSplice b)))
                          [("index", TE.decodeUtf8 (maybe "" objid2bs uid))
                          ,("htid",  TE.decodeUtf8 $ objid2bs htid)
                          ,("date",  T.pack $ formatTime defaultTimeLocale "%-m.%d.%Y %r" $ t date)]

renderadddel people who what category when howmuch whopays = 
  [("for", forSplice whopays)] ++
  (map ((\(a,b) -> (a, textSplice b)))
    [("who",         TE.decodeUtf8 $ objid2bs who)
    ,("who-old",   "")
    ,("who-class",   "")
    ,("what",       TE.decodeUtf8 what)
    ,("what-old",   "")
    ,("what-class",   "")
    ,("category",   TE.decodeUtf8 category)
    ,("category-old",   "")
    ,("category-class",   "")
    ,("when",       T.pack $ show when)
    ,("when-old",   "")
    ,("when-class",   "")
    ,("ammount",     T.pack $ moneyShow howmuch)
    ,("ammount-old",   "")
    ,("ammount-class",   "")
    ,("forSummary", T.pack $ (showPeople people whopays))
    ,("forSummary-old",   "")
    ,("forSummary-class",   "")
    ])

renderChangeT :: Monad m => T.Text -> (a -> T.Text) -> Change a -> [(T.Text,Splice m)]
renderChangeT n f = renderChange n (textSplice . f)

renderChange :: Monad m => T.Text -> (a -> Splice m) -> Change a -> [(T.Text,Splice m)]
renderChange n f (Change old new) = [(n, f (fromMaybe old new))
                                    ,(T.concat [n,"-old"], maybe (textSplice "") (const (f old)) new)
                                    ,(T.concat [n,"-class"], maybe (textSplice "nm") (const (textSplice "")) new)]


renderHistory :: [Person] -> [History] -> Splice Application
renderHistory people hs = do
  zone <- liftIO getCurrentTimeZone
  mapSplices (renderHistoryChild (utcToLocalTime zone) people) hs