--This module is designed to implement the steps described in https://developer.yahoo.com/oauth2/guide/flows_authcode/
local store2 = require 'store2'
local YahooOAuth2 = {}

-- Step 1 

local ClientID = 'dj0yJmk9RHRkdEVVUWVmN2hFJmQ9WVdrOVZGRkhhM2xGTWpZbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PTY1'
local secret = '5af118064d786cf3c0c25164a8bc552f2903ad96'
local appID = 'TQGkyE26'

-- Step 2 and 3 (Step 3 is just user redirecting back to yahoo/response)

function YahooOAuth2.requestAuth()

   local redirectString = 'https://api.login.yahoo.com/oauth2/request_auth?client_id='..ClientID..
   '&redirect_uri=https://localhost:6544/yahoo/response&response_type=code&language=en-us'
   trace(string)
   net.http.respond
   {
      body='This is my response',
      code = 301,
      headers=
      { 
         ['Location']= redirectString
      }
   }

end

-- Step 4

function YahooOAuth2.getInitialAccess(code)

   local tokenResp = net.http.post{url='https://api.login.yahoo.com/oauth2/get_token',
      body='grant_type=authorization_code'..
      '&redirect_uri='..
      'https://localhost:6544/yahoo/response'..
      '&code='..code,
      headers={
         ['Authorization'] = 'Basic '..filter.base64.enc(ClientID..':'..secret),
         ['Content-Type'] = 'application/x-www-form-urlencoded'
      },
      live=true
   } 

   local tokens = json.parse{data=tokenResp}
   trace(tokens)

   
   local localStore = store2.connect(iguana.project.guid())
   localStore:put("refresh",tokens.refresh_token)
   localStore:put("token", tokens.access_token)
   localStore:put("expires", os.ts.time() + tokens.expires_in)


   -- assign token either from local store or from call access token
   returnToken = tokens.access_token
   return returnToken

end


-- Step 5

function YahooOAuth2.getToken()
   -- Fetch local store for token and expires
   local returnToken = ''
   local localStore = store2.connect(iguana.project.guid())
   local token = localStore:get("token")
   local expires = localStore:get("expires")
   -- Check if token expired
   if (token == nil or expires == nil)
      or
      (expires ~= nil and (expires + 0) <= os.ts.time())
      then
      local refreshtoken = localStore:get('refresh')

      
      local res = net.http.post{url='https://api.login.yahoo.com/oauth2/get_token',
         body='grant_type=refresh_token'..
         '&redirect_uri='..
         'https://localhost:6544/yahoo/response'..
         '&refresh_token='..refreshtoken,
         headers={
            ['Authorization'] = 'Basic '..filter.base64.enc(ClientID..':'..secret),
            ['Content-Type'] = 'application/x-www-form-urlencoded'
         },
         live=true
      }
      -- Parse out authentication token
      if res ~= '' then
         local resData = json.parse{data=res}
         localStore:put("token", resData.access_token)
         localStore:put("expires", os.ts.time() + resData.expires_in)
         token = resData.access_token
      end
   end
   -- assign token either from local store or from call access token
   returnToken = token
   return returnToken
end

return YahooOAuth2