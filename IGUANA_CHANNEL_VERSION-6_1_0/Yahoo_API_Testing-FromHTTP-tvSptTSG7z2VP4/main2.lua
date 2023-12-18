-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.

--First try, OAuth client type confidential
--local ClientID = 'dj0yJmk9VG04NWFRa3VLblQ1JmQ9WVdrOWFqa3haR2hHVXpjbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PTIy'
--local secret = '9184daa73ce8862eb402f7bdb5248b6801d9f7b8'
--local appID = 'j91dhFS7'

local ClientID = 'dj0yJmk9MXZnUnVjSE1LbERZJmQ9WVdrOVFYSlNSbWQ2U1drbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PWVl'
local appID = 'ArRFgzIi'

local team = '418.l.103152.t.9'

local rosterchange = '<?xml version="1.0"?><fantasy_content><roster><coverage_type>date</coverage_type><date>2011-05-01</date><players><player><player_key>253.p.8332</player_key><position>1B</position></player></players></roster></fantasy_content>'
local rosterchangexmlREALONE = xml.parse(rosterchange)
local getoken = 'https://api.login.yahoo.com/oauth2/get_token'
local getokentest = 'https://localhost:6544/echo'
local xmlstr = '{"access_token":"SfXIHiWZ5BuQfiDKTAt5BDfwkX_LICGSyQ2NG2i_msg5_CTO5itTN2DHMO_wu_sSMiaYnXlF_rvwOIxFerpc.XXIgdXUnKqBaN05y_GxAtkucQEcoHjak5oteekM3HQe.V3DcXBisXEC_8WcFVTx0gwChWyOF6PyzqtumSFMxzC37KBr3PcnXV18RsXRnfs.sJG0FJwdumwGboSrKwrL8pkuyI9RSfcCdrUikMvIXltjDydQYBvH.gxc4Rmcs79pQRiW_Wt6gLU2SiakHLuWXVWbe64j2hNbk_zGfk95IbRkCkhrKfRy0_6bcca2hugPgQmunexCOuBTqN7R.LnahiHIbPWY5lsR_UR2DyIq8Xjq79GeDwEOmUhX7kX.GdWLFJSYw29isPhZ3P4Dy.Xpj8v2Obk78If9pgFeRpRGZt_fzNvJz8s.k1TEq6HqzrNAwdL5nzEiFh_vjueYJV6XgCTkbKDUt_VGGs8ySNXsJfoJRo2F5z857TPsF_5ozyBkk002Ivr8vrVju8u2ZLPoLTr52cIgxOLyRSn_CAWgFk9JSKrtG0nPH8XRK4gydTOsQ37rbeF4ERTRxHMo8xJOdJK0Brj2y0Fl_IWJXGJuqdX.J5f.wy33O4IyHcsaqbdKcYjK0PIyRwA3iBxdP_7t8abMHm1PZDLtMZkKYgiqvBUpsSEkaTIRhoi8QdRoLwEfx9i9AmBMKyyhU45I1Iz1U8eKvDPdh4.2kTIDwJFeUYqJQgg.MA00g2J9P71iuDQFOezmptBJipLN5oqVfl1Qe9DW8nXkRQ1VcLmGc37Tk.k3G6jG9Qo_PzLmgxR5u0HrnWAf.4CFwR0dc_ypwDOM.vIcPW0CWQanCZgSc5yn6CEaziU8D85Bh5GPlBzwxOndXqTbUr5bYbhB9sHCP0kKIMaCNZEJVgP_VekPrZVk8Olk3ynIaBK921f0qGR3RO6mXEZPdXAflJvd5KotJEzVEKRnqjDg4GPIJA--","refresh_token":"ALRRbWNl.jElRlyLhnG.DqbCkTyW.U_flPDtL_HIhx12bsL7mpGbfXSBGK9VPg--","expires_in":3600,"token_type":"bearer"}'

function main()
   
   end

   function ignoreeverything()
   trace(Data)
local parsedxml = json.parse{data=xmlstr}
   
   trace(parsedxml)
   local testing1 = net.http.get{url='https://fantasysports.yahooapis.com/fantasy/v2/team/'..team..'/roster/',parameters={['access_token'] = parsedxml.access_token},live=true}
   trace(testing1)
   trace(xml.parse{data=testing1})
   
   
   
   
   local rosterchangexml = xml.parse{data=testing1}
   if rosterchangexml.fantasy_content ~= nil then
  rosterchangexml.fantasy_content.team.roster.players.player.selected_position.position:setInner('BN')
   rosterchangexml.fantasy_content.team.roster.players:child("player", 2).selected_position.position:setInner('BN')
   
   rosterchangexmlREALONE.fantasy_content.roster.players.player.player_key:setInner(rosterchangexml.fantasy_content.team.roster.players:child("player", 2).player_key:nodeText())
   rosterchangexmlREALONE.fantasy_content.roster.players.player.position:setInner('BN')
   rosterchangexmlREALONE.fantasy_content.roster.date:setInner(rosterchangexml.fantasy_content.team.roster.date:nodeText())
   
   trace(rosterchangexmlREALONE)
   
   
  local putresp,putcode = net.http.put{url='https://fantasysports.yahooapis.com/fantasy/v2/team/'..team..'/roster/',
    --  headers={['Authorization'] = 'Bearer '..parsedxml.access_token,['Content-Type']= 'application/xml',['client_secret']=secret,['host']='https://fantasysports.yahooapis.com/fantasy/v2'},data=rosterchangexmlREALONE,live=true}
      headers={['Authorization'] = 'Bearer '..parsedxml.access_token,['Content-Type']= 'application/xml',['User-Agent']='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.109 Safari/537.36'},data=rosterchangexmlREALONE,live=true}

         
         trace(putresp)
   
   local workalready = rosterchangexml.fantasy_content.team.roster.players.player.selected_position

   trace(workalready)
   
   workalready.position:setInner('BN')
   

   trace(workalready)



   end
   
   local x = net.http.parseRequest{data=Data}
   trace(x)

   local string = 'https://api.login.yahoo.com/oauth2/request_auth?client_id='..ClientID..
   '&redirect_uri=https://localhost:6544/yahoo/response&response_type=code&language=en-us'
   trace(string)
   
   if x.location =='/yahoo/response' then
      local code =    x.get_params.code
      trace(code)

      local y,c = net.http.post{url=getoken,body='grant_type=authorization_code'..
         '&redirect_uri='..
       --  'https%3A%2F%2Flocalhost:6544%2Fyahoo%2Fecho&code='..code,
       -- 'https://localhost:6544/yahoo/response&code=vhbzrhupyxuvq4ah9r5sq54dr5by9nsd',--..code,
         'https://localhost:6544/yahoo/response'..
         '&code='..code,
         
         headers={
            ['Authorization'] = 'Basic '..filter.base64.enc(ClientID..':'..secret),
            ['Content-Type'] = 'application/x-www-form-urlencoded'
         },
         live=true
      }--'grant_type='..code, headers = {[
      trace(y)
      trace(z)
      
      trace(c)
      
   iguana.logInfo(y)










      net.http.respond{body='We made progress, the code is:' .. code}
      return
   elseif x.location =='/yahoo/echo' then
      net.http.respond{body='We made progress ECHO , the code is: 7'}
   elseif x.location =='/yahoo/request' then

      local resp =  net.http.respond{body='This is my response',code = 301,
         headers={ ['Location']= string}}
      trace(resp)
   else 
      net.http.respond{body='How did we get here?'}
   end

end