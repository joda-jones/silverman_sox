#property copyright "joda"
#property link      "https://sora-investment.com/"
#property version   "1.00"
#property strict

/*

*/

#include "CCandle_open.mqh"
#include "CDiscord.mqh"
#include "CSary.mqh"
#include "MyOrders.mqh"
#include "Pos_info_methods_ver1.03.mqh"
#include "Silverman_sox_functions_ver2.00.mqh"

//クラス
Candle_open_array co;
Candle_open co_timer_M15;
Candle_open co_timer_H4;
Each_pos_info_ary epi_ary[];
Sary ary;
//CDiscord discord;
//CDiscord discord_2;

//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int OnInit(){
   
   int i = 0;
   
   TesterHideIndicators(true);
   
   ArrayPrint(ary.sary);
   
   co.set_size(ary.sary_size);
   for(i=0; i<co.array_size; i++){
      co.candle_opens[i].set_init(ary.sary[i].ssymbol, ary.sary[i].observation_timeframe);
   }
   
   ArrayResize(epi_ary, ary.sary_size);
   for(i=0; i<ary.sary_size; i++){
      epi_ary[i].set_necessary(ary.sary[i].magic, Slippage, ary.sary[i].reverse_god);
      epi_ary[i].set_each_pos_info();
   }
   
   //discord.init(Webhook_url);
   
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Ontick                                                           |
//+------------------------------------------------------------------+
void OnTick(){
   
   int i = 0;
   string com = "";
   
   for(i = 0; i<ary.sary_size; i++){
      
      if(!is_between_time(Entry_from_time, Entry_to_time)){
         //Print("between_time()");
         return;
      }
      
      if(!co.candle_opens[i].is_candle_open()){
         continue;
      }   
      
      epi_ary[i].set_each_pos_info();
      //ArrayPrint(epi_ary[i].epi);
      
      if(!ary.sary[i].allow_trade)continue;
      
      Print(ary.sary[i].parms_description + "判定を開始します。");
      //discord.send_discord(EnumToString(gold.gary[i].timeframe),"エントリー条件判定を始めます。");
      
      //変数の宣言---
      MqlTradeRequest request;
      MqlTradeResult result;
      MqlTradeCheckResult tradechekresult;
      ZeroMemory(request);
      ZeroMemory(result);
      ZeroMemory(tradechekresult);
      
      long   digits        = 0;
      double Bid           = 0;
      double Ask           = 0;
      double long_volume   = 0;
      double short_volume  = 0;
      double buy_value     = 0;
      double sell_value    = 0;
      
      int    long_size     = 0;
      int    short_size    = 0;
      
      int    ret_sig_mfi   = 0;
      int    ret_sig_sar   = 0;
      int    sig_entry     = 0;
      
      datetime last_entry  = 0;
      
      request.symbol       = ary.sary[i].ssymbol; //gold.gary[i].gsymbol;
      request.magic        = ary.sary[i].magic; //gold.gary[i].magic;
      request.action       = TRADE_ACTION_DEAL;
      request.deviation    = Slippage;
      request.type_filling = ORDER_FILLING_IOC;
      
      SymbolInfoInteger(ary.sary[i].ssymbol, SYMBOL_DIGITS, digits);
      SymbolInfoDouble(ary.sary[i].ssymbol, SYMBOL_BID, Bid);
      SymbolInfoDouble(ary.sary[i].ssymbol, SYMBOL_ASK, Ask);
      
      ret_sig_sar = sig_sar(ary.sary[i].ssymbol, Bid, ary.sary[i].sar_timeframe, ary.sary[i].h_sar, ary.sary[i].sar_shift);
      
      if(ret_sig_sar==0){
         Print("sig_sar==0");
         continue;
      }
      
      long_volume = ary.sary[i].base_lots;
      if(Compound_interest==true){
         compound_interest(ary.sary[i].base_balance, long_volume);
      }
      long_volume = NormalizeDouble(long_volume, 2);
      
      short_volume = ary.sary[i].base_lots;
      if(Compound_interest==true){
         compound_interest(ary.sary[i].base_balance, short_volume);
      }
      short_volume = NormalizeDouble(short_volume, 2);
      
      if(epi_ary[i].pos_total >= ary.sary[i].max_pos){
         Print("ポジション数オーバー");
         continue;
      }   
      
      last_entry = ary.sary[i].Get_last_open(ary.sary[i].magic);
      datetime timecurrent = TimeCurrent();
      if(TimeCurrent()<last_entry+ary.sary[i].no_entry_min_datetime){
         //Print("No entry time");
         continue;
      }
          
      if(is_over_spread(ary.sary[i].ssymbol, Max_spread)){
         //Print("spread");
         continue;
      }
      
      if(!epi_ary[i].reverse_god){
         if(ret_sig_sar==BUY){
            request.volume  = long_volume;
            request.type    = ORDER_TYPE_BUY;
            request.comment = "";
            SymbolInfoDouble(ary.sary[i].ssymbol, SYMBOL_ASK, request.price);
            request.tp      = request.price + ary.sary[i].tp_price;
            request.sl      = request.price - ary.sary[i].sl_price;
            
            if(OrderCheck(request,tradechekresult)){
               if(tradechekresult.retcode!=TRADE_RETCODE_NO_MONEY){
                  MyOrderSend(request, result);
               }
            }
            
            //discord.send_discord(com);
         }
         else if(ret_sig_sar==SELL){
            request.volume  = short_volume;
            request.type    = ORDER_TYPE_SELL;
            request.comment = "";
            SymbolInfoDouble(ary.sary[i].ssymbol ,SYMBOL_BID, request.price);
            request.tp      = request.price - ary.sary[i].tp_price;
            request.sl      = request.price + ary.sary[i].sl_price;
            
            if(OrderCheck(request,tradechekresult)){
               if(tradechekresult.retcode!=TRADE_RETCODE_NO_MONEY){
                  MyOrderSend(request, result);
               }
            }
            
            //discord.send_discord(com);
         }
      }
      else{
         if(ret_sig_sar==BUY){
            request.volume  = long_volume;
            request.type    = ORDER_TYPE_SELL;
            request.comment = "";
            SymbolInfoDouble(ary.sary[i].ssymbol, SYMBOL_BID, request.price);
            request.tp      = request.price - ary.sary[i].sl_price;
            request.sl      = request.price + ary.sary[i].tp_price;
            
            if(OrderCheck(request,tradechekresult)){
               if(tradechekresult.retcode!=TRADE_RETCODE_NO_MONEY){
                  MyOrderSend(request, result);
               }
            }
       
            //discord.send_discord(com);
         }
         else if(ret_sig_sar==SELL){
            request.volume  = short_volume;
            request.type    = ORDER_TYPE_BUY;
            request.comment = "";
            SymbolInfoDouble(ary.sary[i].ssymbol, SYMBOL_ASK, request.price);
            request.tp      = request.price + ary.sary[i].sl_price;
            request.sl      = request.price - ary.sary[i].tp_price;
            
            if(OrderCheck(request,tradechekresult)){
               if(tradechekresult.retcode!=TRADE_RETCODE_NO_MONEY){
                  MyOrderSend(request, result);
               }
            }
            
            //discord.send_discord(com);
         }
      }   
   
   }
}


//+------------------------------------------------------------------+
//| DeInit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   //discord.send_discord("何らかの原因により、EAが停止しました。");
   EventKillTimer();
}

