module MilleFeuille (Request, Headers, Response, Handler, Middleware, Options, create, stop) where

import Prelude
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import Effect.Aff (Aff)
import Node.HTTP as Node
import Data.Tuple.Nested (type (/\))
import Foreign.Object as Object
import Control.Promise (Promise)
import Control.Promise as Promise

type Request opts = { request :: Node.Request | opts }

type Headers = Array (String /\ String)

type Response body =
  { statusCode :: Int
  , headers :: Headers
  , body :: body
  }

type RawResponse =
  { statusCode :: Int
  , headers :: Object.Object String
  , body :: String
  }

type Handler opts res
  = Request opts
  -> Aff (Response res)

type Middleware handlerOpts handlerRes middleOpts middleRes
  = Handler handlerOpts handlerRes
  -> Request middleOpts
  -> Aff (Response middleRes)

foreign import createImpl
  :: Options
  -> (Node.Request -> Promise RawResponse)
  -> Effect Node.Server

foreign import stopImpl :: Node.Server -> Effect Unit

type Options = { port :: Int }

convertHeaders :: Response String -> RawResponse
convertHeaders res = res { headers = Object.fromFoldable res.headers }

convertHandler
  :: Handler () String
  -> Node.Request
  -> Effect (Promise RawResponse)
convertHandler handler request =
  let correctRequest = { request: request } in
  convertHeaders <$> handler correctRequest # Promise.fromAff

create :: Handler () String -> Options -> Effect Node.Server
create handler options =
  createImpl options \request ->
    unsafePerformEffect $ convertHandler handler request

stop :: Node.Server -> Effect Unit
stop = stopImpl
