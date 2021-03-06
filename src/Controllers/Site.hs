{-# LANGUAGE OverloadedStrings #-}

module Controllers.Site
  ( site
  ) where

import            Control.Applicative
import            Control.Monad
import            Control.Monad.Trans (liftIO)
import            Data.Maybe
import qualified  Data.Text.Encoding as TE
import qualified  Data.Text as T
import            Snap.Extension.Heist
import            Snap.Extension.Session.CookieSession
import            Snap.Util.FileServe
import            Snap.Types
import            Text.Templating.Heist
import            Snap.Auth
import            Snap.Auth.Handlers
import qualified  Data.Bson as B
import            Snap.Extension.DB.MongoDB hiding (index, label, find)
import qualified  Data.ByteString as BS
import qualified  Data.ByteString.Char8 as B8
import            Data.Time.Clock (getCurrentTime, diffUTCTime)

import            Text.Digestive.Types
import            Text.Digestive.Snap.Heist
import            Text.Digestive.Validate

import            Text.Blaze (Html)
import            Text.XmlHtml (docContent)
import qualified  Text.XmlHtml as X

import            Text.Blaze.Renderer.XmlHtml (renderHtml)
import            Data.List (null, sortBy, find)
import            System.Random (randomRIO)

import            Application
import            Lib
import qualified  Utils as U

import            Heist.Splices.Async
import            Snap.Logging.MongoDB

import            Views.Site
import            Controllers.Account
import            Controllers.Entry
import			  Controllers.Chart
import            Controllers.Person
import            Controllers.History
import            Controllers.Settings
import            Controllers.Tutorial


site :: Application ()                 
site = do
  {-s <- getFromSession "tutorial-step"
  liftIO $ putStrLn $ show s-}
  logAccess $ 
       route [ ("/",                            ifTop $ redirect "/login")
             , ("/entries",                     ifTop $ requireUserBounce' entriesH)
             , ("/entries/page/:page",          requireUserBounce' entriesPageH)
             , ("/entries/add",                 requireUserBounce' $ addEntry)              
             , ("/entries/show/:id",            requireUserBounce' $ showEntry)              
             , ("/entries/edit/:id",            requireUserBounce' $ editEntry)              
             , ("/entries/delete/:id",          requireUserBounce' $ deleteEntry)
			 , ("/charts",						requireUserBounce' $ showCharts)           
             , ("/people/add",                  requireUserBounce' $ addPerson)
             , ("/people/list",                 requireUserBounce $ listPeople)
             , ("/people/:person",              requireUserBounce' $ personH)
             , ("/people/edit/:id",             requireUserBounce' $ editPerson)
             , ("/tutorial/deactivate",         requireUserBounce' $ tutorialDeactivate)
             , ("/tutorial/activate",           requireUserBounce' $ tutorialActivate)
             , ("/settings",                    ifTop $ requireUserBounce' settingsH)
             , ("/settings/update",             requireUserBounce' changeSettingsH)
             , ("/history/page/:page",          requireUserBounce' historyPageH)
             , ("/history/activate",            ifTop $ requireUserBounce' activateHistory)
             , ("/history/deactivate",          ifTop $ requireUserBounce' deactivateHistory)
             , ("/about",                       ifTop $ noRequireUser $ renderHT "about")
             , ("/account/delete",              method POST $ requireUserBounce' deleteAccountH)
             , ("/account/forgot",              method GET $ renderHT "account/forgot")
             , ("/account/forgot",              method POST $ noRequireUser forgotPasswordH)
             , ("/signup",                      renderHT "account/signup")
             , ("/signup/form",                 noRequireUser $ signupH)
             -- if they are logged in already, redirect to entries
             , ("/login",                       requireUser mzero $ redirect "/entries#navbar")
             , ("/login",                       method GET $ noRequireUser $ loginH)
             , ("/login",                       method POST $ noRequireUser $ loginHandler "password" Nothing (const loginFailure) loginSuccess)
             , ("/logout",                      method GET $ noRequireUser $ logoutHandler redirTo)
             , ("/activate",                    noRequireUser $ activateAccountH)
             , ("/changeemail",                 noRequireUser $ changeEmailH)
             , ("/reset",                       noRequireUser $ resetPasswordH)
             ]
       <|> serveDirectory "resources/static"
