-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
local YahooOAuth2 = require 'YahooOAuth2'
local store2 = require 'store2'

local ClientID = 'dj0yJmk9VG04NWFRa3VLblQ1JmQ9WVdrOWFqa3haR2hHVXpjbWNHbzlNQT09JnM9Y29uc3VtZXJzZWNyZXQmc3Y9MCZ4PTIy'
local secret = '9184daa73ce8862eb402f7bdb5248b6801d9f7b8'
local appID = 'j91dhFS7'

local team = '418.l.103152.t.9'
local league = '418.l.103152'

local function transactionFun()

   local token = YahooOAuth2.getToken()


   local transaction = net.http.get{url='https://fantasysports.yahooapis.com/fantasy/v2/league/'..league..'/transactions;team_key='..team..';type=waiver',parameters={['access_token'] = token},live=true}
   trace(transaction)
   trace(xml.parse{data=transaction})

   --cancel a pending waiver claim 
   local waiverid = '418.l.103152.w.c.9_6694_5754'--this is leaguge id plus w.c plus add player plus drop player with underscores

   -- local cancel = net.http.delete{url='https://fantasysports.yahooapis.com/fantasy/v2/transaction/'..waiverid,headers={['Authorization'] = 'Bearer '..token},live=true}
   -- trace(cancel)

   --add/drop a player 
   local playeridADD = '418.p.6053'--bruce brown, '418.p.6694'--keegan murray
   local playeridDROP = '418.p.5754'--caruso

   local addropxml = '<fantasy_content><transaction><type>add/drop</type><players><player><player_key>'..
   playeridADD..'</player_key><transaction_data><type>add</type><destination_team_key>'..
   team..'</destination_team_key></transaction_data></player><player><player_key>'..
   playeridDROP..'</player_key><transaction_data><type>drop</type><source_team_key>'..
   team..'</source_team_key></transaction_data></player></players></transaction></fantasy_content>'

   local addrop = net.http.post{url='https://fantasysports.yahooapis.com/fantasy/v2/league/'..league..'/transactions', 
      headers={['Authorization'] = 'Bearer '..token,['Content-Type']= 'application/xml'},body=addropxml,live=false}

   trace(addrop)







   -- change roster spot 
   local rosterchange = '<?xml version="1.0"?>\n<fantasy_content>\n<roster>\n<coverage_type>date</coverage_type>\n<date>2022-11-14</date>\n<players>\n<player>\n<player_key>'..
   -- '418.p.6512'
   '5'
   ..'</player_key>\n<position>BN</position>\n</player>\n</players>\n</roster>\n</fantasy_content>'



   trace(testingput)

   local putresp,putcode = net.http.put{url='https://fantasysports.yahooapis.com/fantasy/v2/team/'..team..'/roster/',
      headers={['Authorization'] = 'Bearer '..token,['Content-Type']= 'application/xml'},
      data=rosterchange,live=false}


end

local function getAllRosteredPlayers()

   local everyrosteredplayer ={}

   local token = YahooOAuth2.getToken()

   for i=1,12 do 

      local everyplayer = net.http.get{url='https://fantasysports.yahooapis.com/fantasy/v2/team/'..league..'.t.'..i..'/roster',parameters={['access_token'] = token},live=true}
      everyplayer = xml.parse{data=everyplayer}.fantasy_content.team.roster.players
      trace(everyplayer)

      for j = 1,  (#everyplayer-1) do 

         table.insert(everyrosteredplayer,everyplayer:child('player',j).name.full:nodeText())

      end

   end

   return everyrosteredplayer
end

local function calcMatchup(oppName,oppStats,myStats)
   local tempTallyTable = {}
   local tempTable = {}

   local index = {'RAW FG','FG%','RAW FT','FT%','Threes','Points',
      'Rebounds','Assists','Steals','Blocks','Turnovers'}
   trace(index)

   for i=1, myStats:childCount('stat') do
      if (i == 1 or i == 3) then
      elseif i ==11 then
         tempTallyTable[index[i]] = 0 

         local x = tonumber(myStats:child('stat',i).value:nodeText())
         trace(x)
         local y = tonumber(oppStats:child('stat',i).value:nodeText())
         trace(y)
         if x>y then
            tempTable[index[i]] = 'L'

         elseif x<y then

            tempTable[index[i]] = 'W'
            tempTallyTable[index[i]] =tempTallyTable[index[i]] +1

         else
            tempTable[index[i]] = 'T'
         end
      else
         tempTallyTable[index[i]] = 0 

         local x = tonumber(myStats:child('stat',i).value:nodeText())
         trace(x)
         local y = tonumber(oppStats:child('stat',i).value:nodeText())
         trace(y)

         if x>y then
            tempTable[index[i]] = 'W'
            tempTallyTable[index[i]] =tempTallyTable[index[i]] +1

         elseif x<y then
            tempTable[index[i]] = 'L'

         else
            tempTable[index[i]] = 'T'
         end

      end
   end
   return tempTable,tempTallyTable
end


local function getAllMatchups()

   local myWinCount = {}
   local tempWinCount = {}
   local allStats = {}
   local myStats = {}
   local weeklyStats = {}
   local allWinCounts = {}
   local allMatchups = {}
   local weeklyMatchups = {}
   local index = {'RAW FG','FG%','RAW FT','FT%','Threes','Points',
      'Rebounds','Assists','Steals','Blocks','Turnovers'}




   local token = YahooOAuth2.getToken()

   local weeklyinfo = net.http.get{url='https://fantasysports.yahooapis.com/fantasy/v2/league/'..league..'/scoreboard',parameters={['access_token'] = token},live=true}
   weeklyinfo = xml.parse{data=weeklyinfo}

   local weekindex = tonumber(weeklyinfo.fantasy_content.league.scoreboard.week:nodeText())-1


   for week =1,weekindex do 


      local weekResp = net.http.get{url='https://fantasysports.yahooapis.com/fantasy/v2/league/'..league..'/scoreboard;week='..week,parameters={['access_token'] = token},live=true}
      weekResp = xml.parse{data=weekResp}.fantasy_content.league.scoreboard.matchups
      trace(weekResp)
      for i=1,weekResp:childCount('matchup') do 
         for j = 1, 2 do 
            local teamname = weekResp:child('matchup',i).teams:child('team',j).name:nodeText()
            local stats = weekResp:child('matchup',i).teams:child('team',j).team_stats.stats
            weeklyStats[teamname] = stats
         end
      end
      trace(weeklyStats)
      myStats = weeklyStats["Harden’s Hoes"]
      trace(myStats)
      weeklyMatchups = {}
      myWinCount = {}
      for i=1,11 do
         if (i~=1 and i~=3) then
            myWinCount[index[i]] = 0  
         end
      end


      for k,v in pairs(weeklyStats) do
         trace(k)
         trace(v)
         trace(myStats)
         if k ~= "Harden’s Hoes" then
            weeklyMatchups[k],tempWinCount =  calcMatchup(k,v,myStats)
            for i = 1, 11 do 
               if (i~=1 and i~=3) then
                  myWinCount[index[i]] = myWinCount[index[i]] + tempWinCount[index[i]]
               end
            end
            trace(myWinCount)
         end
         trace(weeklyMatchups)

      end
      trace(myWinCount)

      trace(weeklyMatchups)
      weeklyMatchups['Results']=myWinCount
      trace(weeklyMatchups)
      allMatchups['Week '..week] = weeklyMatchups
      allWinCounts['Week '..week] = myWinCount
      -- allMatchups['Week '..week]['Results'] = myWinCount

      trace(allMatchups)
      trace(allWinCounts)

   end
   trace(myWinCount)
   trace(allWinCounts)
   trace(allMatchups)
   return allMatchups,allWinCounts
end




function main(Data)


   local x = net.http.parseRequest{data=Data}
   trace(x)

   if x.location =='/yahoo/response' then

      local code =    x.get_params.code
      trace(code)
      net.http.respond{body='We made progress, the code is:' .. code}

      local y = YahooOAuth2.getInitialAccess(code)


   elseif x.location =='/yahoo/request' then

      YahooOAuth2.requestAuth()

   elseif x.location =='/yahoo/anotherresponse' then
      net.http.respond{body='I think we sucessfully requested auth'}

   elseif x.location =='/yahoo/response3'then

      net.http.respond{body='I think we did a refresh'}

   elseif x.location =='/yahoo/testing' then

      local stats,wins = getAllMatchups()
      winstr = json.serialize{data=wins}
      statstr = json.serialize{data=stats}

      local transaction = transactionFun()

      local token = YahooOAuth2.getToken()

     -- local weeklyinfo, code = net.http.get{url='http://fantasysports.yahooapis.com/fantasy/v2/league/'..league..'/players;status=A',parameters={['access_token'] = token},live=true}
        local weeklyinfo, code = net.http.get{url='https://localhost:6544/echo000',parameters={['access_token'] = token},live=true}

      trace(code)
      weeklyinfo = xml.parse{data=weeklyinfo}
      trace(weeklyinfo.fantasy_content.league.players:childCount("player"))
      local rostered = getAllRosteredPlayers()
      trace(json.serialize{data=rostered})


      



      net.http.respond{body =winstr..statstr,entity_type='json'}



   elseif x.location =='/yahoo/testingput' then

      token = YahooOAuth2.getToken()

      local rosterchange = '<?xml version="1.0"?>\n<fantasy_content>\n<roster>\n<coverage_type>date</coverage_type>\n<date>2022-11-14</date>\n<players>\n<player>\n<player_key>'..
      -- '418.p.6512'
      '5'
      ..'</player_key>\n<position>BN</position>\n</player>\n</players>\n</roster>\n</fantasy_content>'



      trace(testingput)

      local putresp,putcode = net.http.put{url='https://fantasysports.yahooapis.com/fantasy/v2/team/'..team..'/roster/',
         headers={['Authorization'] = 'Bearer '..token,['Content-Type']= 'application/xml'},
         data=rosterchange,live=true}
      trace(putresp)
      net.http.respond{body =putresp,entity_type='xml'}
   else
      net.http.respond{body='I think we got lost, how did we get here?'}

   end

end