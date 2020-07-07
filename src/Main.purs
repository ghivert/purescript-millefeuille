module Main where

import Prelude

import Effect (Effect)
import Effect.Console as Console
import MilleFeuille as MilleFeuille
import Data.Tuple.Nested ((/\), type (/\))
import Data.Array ((:))
import Record as Record
import Data.Symbol (SProxy(..))

response :: forall body. body -> MilleFeuille.Response body
response = { statusCode: 200, headers: [], body: _ }

jsonContentType :: String /\ String
jsonContentType = "Content-Type" /\ "application/json"

addJSONContentType :: forall a b. MilleFeuille.Middleware a b a b
addJSONContentType hand req =
  hand req <#> \res -> res { headers = jsonContentType : res.headers }

handler :: MilleFeuille.Handler (test :: String) (Array Int)
handler request = pure $ response [1]

middle :: MilleFeuille.Middleware (test :: String) (Array Int) () String
middle hand req = do
  res <- hand $ Record.insert (SProxy :: SProxy "test") "test" req
  pure $ res { body = show res.body }

main :: Effect Unit
main = do
  let options = { port: 9999 }
  server <- MilleFeuille.create (addJSONContentType $ middle handler) options
  Console.log "🚀  Server started."
  pure unit
