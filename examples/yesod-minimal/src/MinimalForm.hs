{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
module MinimalForm where

import           Control.Applicative      ((<$>), (<*>))
import           Data.Text                (Text)
import           Network.Wai.Handler.Warp (run)
import           Yesod.Core               (HandlerFor, Html, RenderMessage (..),
                                           RenderRoute (..), Yesod (..), hamlet,
                                           mkYesod, pageBody, pageHead,
                                           pageTitle, parseRoutes, setTitle,
                                           toWaiApp, whamlet,
                                           widgetToPageContent, withUrlRenderer)
import           Yesod.Form               (FormMessage (..), FormResult (..),
                                           MForm, Option (..), areq,
                                           defaultFormMessage, intField,
                                           mkOptionList, renderDivs,
                                           runFormPost, selectField, textField)

data Minimal = Minimal

mkYesod "Minimal" [parseRoutes|
    / RootR GET POST
|]

type Form x = Html -> MForm (HandlerFor Minimal) (FormResult x, Widget)

instance Yesod Minimal where
    defaultLayout widget = do
        pc <- widgetToPageContent widget
        withUrlRenderer [hamlet|
            \<!DOCTYPE html>
            <html lang="en">
                <head>
                    <meta charset="utf-8">
                    <title>#{pageTitle pc}
                    <meta name="description" content="my awesome site">
                    <meta name="author" content="Patrick Brisbin">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    ^{pageHead pc}
                <body>
                    ^{pageBody pc}
            |]

instance RenderMessage Minimal FormMessage where
    renderMessage _ _ = defaultFormMessage

data Fruit = Apple | Orange | Pear deriving (Eq, Ord, Read, Show)

data TheForm = TheForm
    { formText  :: Text
    , formInt   :: Int
    , formFruit :: Fruit
    }

theForm :: Form TheForm
theForm = renderDivs $ TheForm
    <$> areq textField   "Some text"   Nothing
    <*> areq intField    "Some number" Nothing
    <*> areq selectFruit "Some fruit"  Nothing

    where
        selectFruit = selectField $ return $ mkOptionList [ Option "Apple" Apple "apple"
                                                          , Option "Orange" Orange "orange"
                                                          , Option "Pear" Pear "pear"
                                                          ]

getRootR :: Handler Html
getRootR = do
    ((res, form), enctype ) <- runFormPost theForm
    defaultLayout $ do
        setTitle "My title"

        case res of
            FormSuccess f -> [whamlet|
                                <p>You've posted a form!
                                <p>the text was #{formText f}
                                <p>the number was #{formInt f}
                                <p>the fruit was #{show $ formFruit f}
                                |]

            _ -> [whamlet|
                    <p>Hello world!
                    <form enctype="#{enctype}" method="post">
                        ^{form}
                        <input type="submit">
                    |]


postRootR :: Handler Html
postRootR = getRootR

main :: IO ()
main = run 3000 =<< toWaiApp Minimal
