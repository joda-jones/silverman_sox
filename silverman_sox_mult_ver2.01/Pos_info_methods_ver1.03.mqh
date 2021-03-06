//+------------------------------------------------------------------+
//|                                                     Pos_info.mqh |
//|                                                            jones |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      ""

#include "Pos_info_ver1.03.mqh"

/*
MyOrdersファイルをincludeする必要があります。

ロング、ショートそれぞれのポジション数や平均コストなどのポジション情報を取得、格納するクラス
主な機能
ポジション数
平均コスト
トレイリングストップ
個別にTP設定
*/

//+------------------------------------------------------------------+
//| Each_pos_info                                                    |
//+------------------------------------------------------------------+
Each_pos_info::Each_pos_info(void){
   
   //necessary
   symbol        = "";
   lots          = 0;       //          
   op            = 0;         //
   virtual_tp    = 0;
   virtual_sl    = 0;
   trailing_sl   = 0;
   entry_time    = 0; //エントリー時間 datetime
   ticket        = 0;     //
   magic         = 0;
   close_trigger = false;
   
   //type;
}


//+------------------------------------------------------------------+
//| Strage_virtual_price                                             |
//+------------------------------------------------------------------+
Strage_virtual_price::Strage_virtual_price(void){
   
   v_tp = 0;
   v_sl = 0;
   v_trail_sl = 0;
   ticket = 0;
   
}


//+------------------------------------------------------------------+
//| Each_pos_info_ary                                                |
//+------------------------------------------------------------------+
void Each_pos_info_ary::Each_pos_info_ary(void){
   pos_total = 0;
   
   ArrayFree(epi);
   ArrayFree(str_vir_price);
   
}


void Each_pos_info_ary::set_necessary(long mag, int sli,bool ts_mode){
   
   magic       = mag;
   slippage    = sli;
   reverse_god = ts_mode;
   
}

void Each_pos_info_ary::set_each_pos_info(void){
   
   int i = 0;
   int j = 0;
   int str_vir_price_size = 0;
   int before_size = 0;
   int all_pos_total = 0;
   
   pos_total = 0;
   all_pos_total = PositionsTotal();
   
   //str_vir_price initialize
   ArrayFree(str_vir_price);
   str_vir_price_size = ArraySize(epi);
   ArrayResize(str_vir_price, str_vir_price_size, 100);
   /*
   Print("###############epi######################");
   ArrayPrint(epi);
   Print("");
   Print("###############freed str_vir_price######################");
   ArrayPrint(str_vir_price);
   */
   
   //store epi[] value
   for(i=0; i<str_vir_price_size; i++){
      str_vir_price[i].ticket     = epi[i].ticket;
      str_vir_price[i].v_tp       = epi[i].virtual_tp;
      str_vir_price[i].v_sl       = epi[i].virtual_sl;
      str_vir_price[i].v_trail_sl = epi[i].trailing_sl;
   }
   
   //epi配列を開放
   ArrayFree(epi);
   
   if(all_pos_total==0)return;
   for(i=0; i<all_pos_total; i++){
      
      //indexからポジションを選択
      mql_posinfo.SelectByIndex(i);
      
      //magicが一致しているとき
      if(mql_posinfo.Magic()!=magic)continue;
      
      //epiのサイズを変更
      before_size = ArraySize(epi);
      ArrayResize(epi, before_size+1, 100);
      
      //必要情報を入力
      epi[before_size].symbol     = mql_posinfo.Symbol();
      epi[before_size].lots       = mql_posinfo.Volume();
      epi[before_size].op         = mql_posinfo.PriceOpen();
      epi[before_size].entry_time = mql_posinfo.Time();
      epi[before_size].ticket     = mql_posinfo.Ticket();
      epi[before_size].magic      = mql_posinfo.Magic();
      epi[before_size].type       = mql_posinfo.PositionType();
      
      //Store virtual_price if tickets match
      for(j=0; j<str_vir_price_size; j++){
         if(str_vir_price[j].ticket==epi[before_size].ticket){
            epi[before_size].virtual_tp  = str_vir_price[j].v_tp;
            epi[before_size].virtual_sl  = str_vir_price[j].v_sl;
            epi[before_size].trailing_sl = str_vir_price[j].v_trail_sl;
         }
      }
      
      pos_total++;
      
   }
   /*
   Print("");
   Print("#########Entered epi#####################");
   ArrayPrint(epi);
   */
}

void Each_pos_info_ary::get_long_num(int& ret){
   /*
   set_eachpos_info()実行が必要なので注意
   */
   
   int i   = 0;
   
   for(i=0; i<pos_total; i++){
      if(epi[i].type==POSITION_TYPE_BUY){
         ret++;
      }   
   }
}

void Each_pos_info_ary::get_short_num(int& ret){
   /*
   set_eachpos_info()実行が必要なので注意
   */
   
   int i   = 0;
   
   for(i=0; i<pos_total; i++){
      if(epi[i].type==POSITION_TYPE_SELL){
         ret++;
      }   
   }
}

void Each_pos_info_ary::get_last_entry_time(datetime& ret){
   
   /*
   set_eachpos_info()実行が必要なので注意
   */
   
   int i = 0;
   
   for(i=0; i<pos_total; i++){
      if(epi[i].entry_time>ret){
         ret = epi[i].entry_time;
      }
   }
   
}

bool Each_pos_info_ary::ts_from_op(double price,double margin_price){
   
   /*
   set_eachpos_info()実行が必要なので注意
   */
   
   if(slippage==0)return(false);
   
   bool   long_flag  = false;
   bool   short_flag = false;
   int    i          = 0;
   double bid        = 0;
   double ask        = 0;
   
   for(i=0; i<pos_total; i++){
   
      SymbolInfoDouble(epi[i].symbol, SYMBOL_BID, bid);
      SymbolInfoDouble(epi[i].symbol, SYMBOL_ASK, ask);
      
      //ロングトレイリングストップ部分
      if(epi[i].type==POSITION_TYPE_BUY){
         if(bid-epi[i].op>price && epi[i].trailing_sl==0){
            epi[i].trailing_sl = bid-margin_price;
         }
         
         if(epi[i].trailing_sl!=0){
            if(epi[i].trailing_sl<(bid-margin_price)){
               epi[i].trailing_sl = bid-margin_price;
            }
            
            if(bid <= epi[i].trailing_sl){
               epi[i].close_trigger = true;
               ArrayPrint(epi);
               //Print(epi[i].symbol ,epi[i].trailing_sl, bid);
            }   
         }   
      }
      
      //ショートトレイリングストップ部分
      if(epi[i].type==POSITION_TYPE_SELL){
         if(epi[i].op-ask > price && epi[i].trailing_sl==0){
            epi[i].trailing_sl = ask + margin_price;
         }
         
         if(epi[i].trailing_sl!=0){
            if(epi[i].trailing_sl>(ask+margin_price)){
               epi[i].trailing_sl = ask + margin_price;
            }
            
            if(ask>=epi[i].trailing_sl){
               epi[i].close_trigger = true;
               ArrayPrint(epi);
               //Print(epi[i].symbol ,epi[i].trailing_sl, bid);
            }   
         }   
      }      
   }   
      
   for(i=0; i<pos_total; i++){
      if(epi[i].close_trigger){
         if(MyOrderClose(slippage, epi[i].ticket)){
            //Print("#################close by ts_from_op#######################");
            epi[i].close_trigger = false;
            epi[i].trailing_sl = 0;
         }
      }   
   }   
   
   return(true);
   
}

bool Each_pos_info_ary::ts_from_op_reverse(double price,double margin_price){
   
   /*
   set_eachpos_info()実行が必要なので注意
   */
   
   if(slippage==0)return(false);
   
   bool   long_flag  = false;
   bool   short_flag = false;
   int    i          = 0;
   double bid        = 0;
   double ask        = 0;
   
   for(i=0; i<pos_total; i++){
   
      SymbolInfoDouble(epi[i].symbol, SYMBOL_BID, bid);
      SymbolInfoDouble(epi[i].symbol, SYMBOL_ASK, ask);
      
      //ロングトレイリングストップ部分
      if(epi[i].type==POSITION_TYPE_BUY){
         
         if(epi[i].op-bid>price && epi[i].trailing_sl==0){
            epi[i].trailing_sl = bid + margin_price;
         }
         
         if(epi[i].trailing_sl!=0){
            if(epi[i].trailing_sl>(bid+margin_price)){
               epi[i].trailing_sl = bid + margin_price;
            }
            
            if(bid >= epi[i].trailing_sl){
               epi[i].close_trigger = true;
               ArrayPrint(epi);
            }   
         }   
      
      }
      
      
      //ショートトレイリングストップ部分
      if(epi[i].type==POSITION_TYPE_SELL){
         if(ask-epi[i].op > price && epi[i].trailing_sl==0){
            epi[i].trailing_sl = ask - margin_price;
         }
         
         if(epi[i].trailing_sl!=0){
            if(epi[i].trailing_sl<(ask-margin_price)){
               epi[i].trailing_sl = ask - margin_price;
            }
            
            if(ask<=epi[i].trailing_sl){
               epi[i].close_trigger = true;
               ArrayPrint(epi);
            }   
         }
      }
  
   }   
      
   for(i=0; i<pos_total; i++){
      if(epi[i].close_trigger){
         if(MyOrderClose(slippage, epi[i].ticket)){
            //Print("#################close by ts_from_op#######################");
            epi[i].close_trigger = false;
            epi[i].trailing_sl = 0;
         }
      }   
   }   
   
   return(true);
   
}

bool Each_pos_info_ary::trailing_stop(double price,double margin_price){
   
   if(reverse_god){
      ts_from_op_reverse(price, margin_price);
   }
   else{
      ts_from_op(price, margin_price);
   }
   
   return(true);
}

//+------------------------------------------------------------------+
//| Pos_info                                                         |
//+------------------------------------------------------------------+
void Pos_info::Pos_info(void){
   
   symbol           = "";
   magic            = 0;
   slippage         = 0;

   long_lots        = 0;          
   long_price_lots  = 0;
   long_swap        = 0;
   long_comi        = 0;
   long_ap          = 0;

   short_lots       = 0;
   short_price_lots = 0;
   short_swap       = 0;
   short_comi       = 0;
   short_ap         = 0;
   
   long_last_time   = 0;
   short_last_time  = 0;
   
   new_sl_buy       = 0;
   new_sl_sell      = 0;    
   
   long_num         = 0;
   short_num        = 0;
   
   reverse_god      = false;
   
   ArrayFree(long_ticket);
   ArrayFree(short_ticket);
   ArrayFree(long_tp);
   ArrayFree(short_tp);
   
}

void Pos_info::Pos_info(string sym, int mag, int sli, bool entry_mode=false, bool trailing_mode=false){ //ひきすう
   
   symbol           = sym; //くらすめんばにしんぼるをだいにゅう
   magic            = mag; //くらすめんばにまじっくなんばーをだいにゅう
   slippage         = sli;
   reverse_god      = entry_mode;    //trueで逆注文ﾓｰﾄﾞ
   trailing_from_op = trailing_mode; //trueで各OPからトレイリングストップ
   
   long_lots        = 0; //ロングの合計ロット          
   long_price_lots  = 0; //ロングのオープン価格×ロット
   long_swap        = 0; //ロングのスワップ1
   long_comi        = 0; //ロングの手数料
   long_ap          = 0; //ロングの平均コスト
   
   short_lots       = 0; //ショートの合計ロット
   short_price_lots = 0; //ショートのオープン価格×ロット
   short_swap       = 0; //ショートのスワップ
   short_comi       = 0; //ショートの手数料
   short_ap         = 0; //ショートの平均コスto
   
   long_last_time   = 0;
   short_last_time  = 0;
   
   long_num         = 0; //ロングのポジション数
   short_num        = 0; //ショートのポジション数
   
   new_sl_buy       = 0;
   new_sl_sell      = 0;
   
   ArrayFree(long_tp);
   ArrayFree(short_tp);
   
   ulong ticket = 0;
   int i      = 0;
   
   epi_ary.set_each_pos_info();
        
   for(i=0; i<epi_ary.pos_total; i++){
      if(epi_ary.epi[i].type==POSITION_TYPE_BUY){        //longだったときカウンターに+1
         long_num++;
         long_lots       += epi_ary.epi[i].lots;
         long_price_lots += epi_ary.epi[i].lots * epi_ary.epi[i].op;
         //long_swap       += epi_ary.epi[i].lots;
      }
      else if(epi_ary.epi[i].type==POSITION_TYPE_SELL){  //shortだったときカウンターに+1
         short_num++;
         short_lots       += epi_ary.epi[i].lots;
         short_price_lots += epi_ary.epi[i].lots * epi_ary.epi[i].op;;
         //short_swap       += PositionGetDouble(POSITION_SWAP);
      }
   }
}

void Pos_info::set_necessary(string sym, int mag, int sli, bool entry_mode=false, bool trailing_mode=false){
   /*
   デフォルトコンストラクタで初期化しないといけない場合用。
   必要なプライベート変数を格納
   */

   symbol      = sym;
   magic       = mag;
   slippage    = sli;
   reverse_god = entry_mode;
   
}

bool Pos_info::set_posinfo(){
   
   if(symbol=="")return(false);
   if(magic==0)return(false);
   
   long_lots        =0; //ロングの合計ロット          
   long_price_lots  =0; //ロングのオープン価格×ロット
   long_swap        =0; //ロングのスワップ1
   long_comi        =0; //ロングの手数料
   long_ap          =0; //ロングの平均コスト
   
   short_lots       =0; //ショートの合計ロット
   short_price_lots =0; //ショートのオープン価格×ロット
   short_swap       =0; //ショートのスワップ
   short_comi       =0; //ショートの手数料
   short_ap         =0; //ショートの平均コスto
   
   long_last_time   = 0;
   short_last_time  = 0;
   
   long_num         =0; //ロングのポジション数
   short_num        =0; //ショートのポジション数
   
   int i      = 0;
        
   epi_ary.set_each_pos_info();
        
   for(i=0; i<epi_ary.pos_total; i++){
      if(epi_ary.epi[i].type==POSITION_TYPE_BUY){        //longだったときカウンターに+1
         long_num++;
         long_lots       += epi_ary.epi[i].lots;
         long_price_lots += epi_ary.epi[i].lots * epi_ary.epi[i].op;
         //long_swap       += epi_ary.epi[i].lots;
      }
      else if(epi_ary.epi[i].type==POSITION_TYPE_SELL){  //shortだったときカウンターに+1
         short_num++;
         short_lots       += epi_ary.epi[i].lots;
         short_price_lots += epi_ary.epi[i].lots * epi_ary.epi[i].op;;
         //short_swap       += PositionGetDouble(POSITION_SWAP);
      }
   }
      
   return(true);
}

bool Pos_info::set_average_price(void){
   
   set_posinfo();
   
   if(long_lots!=0){
      //long_swap  /= TicksToPrice(long_lots*SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE),NULL);
      long_ap = NormalizeDouble(long_price_lots/long_lots, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
   }
   
   if(short_lots!=0){
      //short_swap /= TicksToPrice(short_lots*SymbolInfoDouble(NULL,SYMBOL_TRADE_TICK_VALUE),NULL);
      short_ap = NormalizeDouble(short_price_lots/short_lots, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
   }
   
   return(true);
}

void Pos_info::show_data(void){
   string com   = "";
   int    size0 = 0;
   int    size1 = 0;
   int    i     = 0;
   
   com += "symbol          :"+(string)symbol        + "\n";
   
   com += "long_num        :"+(string)long_num      + "\n";
   com += "long_ap         :"+(string)long_ap       + "\n";
   
   com += "short_num       :"+(string)short_num     + "\n";
   com += "short_ap        :"+(string)short_ap      + "\n";
   
   com += "long_last_time  :"+(string)long_last_time  + "\n";
   com += "short_last_time :"+(string)short_last_time + "\n";
   
   com += "new_sl_buy      :"+(string)new_sl_buy    + "\n";
   com += "new_sl_sell     :"+(string)new_sl_sell   + "\n";

   Print(com);
   
   com   = "";
   size0  = ArraySize(long_ticket);
   size1 = ArraySize(long_tp); 
   
   if(size0 > 0 && size1 > 0){
      for(i=0; i<size0; i++){
         com  += "long_ticket : long_tp -> " +(string)long_ticket[i] + " : " + (string)long_tp[i] + "\n";  
      }
   }
   else if(size0 > 0 && size1 == 0){
      for(i=0; i<size0; i++){
         com  += "long_ticket :" +(string)long_ticket[i] + "\n";  
      }
   }
   Print(com);
   
   com   =  "";
   size0 =  ArraySize(short_ticket);
   size1 = ArraySize(short_tp);
   
   if(size0 > 0 && size1 > 0){
      for(i=0; i<size0; i++){
         com  += "short_ticket : short_tp -> " +(string)short_ticket[i] + " : " + (string)short_tp[i] + "\n";  
      }
   }
   else if(size0 > 0 && size1 == 0){
      for(i=0; i<size0; i++){
         com  += "short_ticket :" +(string)short_ticket[i] + "\n";  
      }
   }
   Print(com);
}

void Pos_info::get_array_size(int& long_size, int& short_size){
   long_size  = ArraySize(long_ticket);
   short_size = ArraySize(short_ticket);
}

bool Pos_info::ts_from_ap(double price, double margin_price){
   /*
   point幅順行したら margin幅のトレイリングストップ開始。
   point,marginはシンボルのpointsに併せておく必要があるので注意。
   */
   if(symbol=="")return(false);
   if(magic==0)return(false);
      
   bool   long_flag  = false;
   bool   short_flag = false;
   int    i          = 0;
   double bid        = 0;
   double ask        = 0;
   
   SymbolInfoDouble(symbol, SYMBOL_BID, bid);
   SymbolInfoDouble(symbol, SYMBOL_ASK, ask);
   
   set_average_price();
   
   //ロングトレイリングストップ部分
   if(bid-long_ap>price && long_ap>0){
      if(new_sl_buy<bid-margin_price || new_sl_buy==0){
         new_sl_buy = bid-margin_price;
      }
   }
   
   if(bid <= new_sl_buy && new_sl_buy!=0)long_flag = true;
   
   //ショートトレイリングストップ部分
   if(short_ap - ask > price){
      if(new_sl_sell > ask + margin_price || new_sl_sell==0){
         new_sl_sell = ask + margin_price;
      }
   }
   
   if(ask >= new_sl_sell && new_sl_sell != 0)short_flag = true;
   
   if(long_flag && short_flag){
      for(i=0; i<epi_ary.pos_total; i++){
         MyOrderClose(slippage, epi_ary.epi[i].ticket);
      }
      new_sl_buy  = 0;     
      new_sl_sell = 0;
   }   
   else if(long_flag && !short_flag){
      for(i=0; i<epi_ary.pos_total; i++){
         if(epi_ary.epi[i].type==POSITION_TYPE_BUY){
            MyOrderClose(slippage, epi_ary.epi[i].ticket);
         }
      }
      new_sl_buy  = 0;       
   }
   else if(long_flag && !short_flag){     
      for(i=0; i<epi_ary.pos_total; i++){
         if(epi_ary.epi[i].type==POSITION_TYPE_SELL){
            MyOrderClose(slippage, epi_ary.epi[i].ticket);
         }
      }
      new_sl_sell  = 0;     
   }
   return(true);
}

