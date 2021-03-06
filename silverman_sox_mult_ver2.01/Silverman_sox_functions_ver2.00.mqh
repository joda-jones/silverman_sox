//+------------------------------------------------------------------+
//|                             aligator_entry_functions_ver1.00.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Function to get the time of the last closed order                |
//+------------------------------------------------------------------+
bool GetTradeHistory(int days){
   /*
   過去数日の履歴をリクエストし、障害が発生した場合にはfalseを返す
   */

   datetime to=TimeCurrent();
   datetime from=to-days*PeriodSeconds(PERIOD_D1);
   ResetLastError();
   
   if(!HistorySelect(from,to)){
      Print(__FUNCTION__," HistorySelect=false. Error code=",GetLastError());
      return(false);
   }
   
   //--- 履歴が正常に受信された
   return(true);
}

bool GetLastOrderTicket(ulong& array[]){
   /*
   過去１日の取引をリクエストする。
   注文が存在した場合、ticketを配列に渡す。
   */
   
   if(!GetTradeHistory(5)){
      Print(__FUNCTION__," HistorySelect() returned false");
      return(false);
   }
   
   int    i     = 0;
   ulong  deals = HistoryDealsTotal();
   //string com   = "";
   
   ArrayFree(array);
   
   if(deals>0){
      ArrayResize(array, (int)deals);
      for(i=0; i<(int)deals; i++){
         array[i] =  HistoryDealGetTicket(i);
         //com      += (string)i + "番目のチケット ：" + (string)array[i] + "\n";
      }
   }
   
   //Print(com);
   
   return(true);
}

datetime Get_last_close(int magic=0){
   /*
   最後に決済したオーダーの決済時刻を渡す。
   DEAL_ENTRY_OUTのdealがない場合、0を返す.
   */
   
   datetime ret        = 0;
   int      array_size = 0;
   int      i          = 0;
   long     deal_magic = 0;
   ulong    deal_tickets[];
   ulong    deal_entry;
   
   //deal_tickets[]にdealのチケットを渡す。
   GetLastOrderTicket(deal_tickets);
   array_size = ArraySize(deal_tickets);
   
   //deal_tickets[]のサイズが0の時、0を返す。
   if(array_size==0){
      return(ret);
   }
   
   //forループでdeal_ticket[]の中身を確認
   //DEAL_ENTRY_OUTだった場合、より時刻が後のものを返す.
   for(i=0; i<array_size; i++){
      HistoryDealGetInteger(deal_tickets[i], DEAL_ENTRY, deal_entry);
      HistoryDealGetInteger(deal_tickets[i], DEAL_MAGIC, deal_magic);
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==magic){
         if(ret<HistoryDealGetInteger(deal_tickets[i], DEAL_TIME)){
            HistoryDealGetInteger(deal_tickets[i], DEAL_TIME, ret);
         }
      }
   }   
   
   return(ret);  
}

//+------------------------------------------------------------------+
//| Convert ticks to prices                                          |
//+------------------------------------------------------------------+
double TicksToPrice(double Ticks, string symbol){
   double price = 0;
   
   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   price = Ticks / MathPow(10, digits);
   
   // 価格を有効桁数で丸める
   price = NormalizeDouble(price, digits);
   
   return(price);
}

double TicksToPrice(int Ticks, string symbol){
   double price = 0;
   
   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   price = (double)Ticks / MathPow(10, digits);
   
   // 価格を有効桁数で丸める
   price = NormalizeDouble(price, digits);
   
   return(price);
}

//+------------------------------------------------------------------+
//| Check spread                                                     |
//+------------------------------------------------------------------+
bool is_over_spread(string symbol, long max_spread){
   
   /*
   指定した通貨ペアのスプレッドがmaxspreadよりも大きいとき、ture 
   */
   
   long spread = 0;
   SymbolInfoInteger(symbol, SYMBOL_SPREAD, spread);
   
   if(spread > max_spread){
      return(true);
   }
   else{
      return(false);
   }
   
   Print("is_over_spread()が機能していない可能性があります。");
   return(false);
   
}



//+------------------------------------------------------------------+
//| Judge of entry time                                              |
//+------------------------------------------------------------------+
bool is_between_time(int from_hour, int to_hour){
   
   /*
   日本時間(hour)が、 from_time ~ to_time の中に含まれる  --> true 
   日本時間(hour)が、 from_time ~ to_time の中に含まれない --> false
   
   ※from_time=10, to_time=12の時のtrue判定になる時間
     -->10時～11時59分59.9999999.......秒まで 12時になった瞬間falseを返す。
   
   ※from_time == to_timeの時
      →from_time 時のときにtrue 
   
   以下の記述をすることを推奨
   if(from_time<0 || from_time>24 || to_time<0 || to_time>24){
      return(INIT_FAILED);
   }
   */
   
   //日本の時間の取得--- 日本時間で from_time時 から to_time時 はエントリーしない
   datetime time = 0;
   MqlDateTime japan_time;

   time = TimeGMT() + 32400;
   TimeToStruct(time, japan_time);
   
   if(from_hour<to_hour){
      if(japan_time.hour >= from_hour && japan_time.hour < to_hour){
         return(true);
      }   
      else{
         return(false);
      }
   }
   else if(from_hour==to_hour){
      if(japan_time.hour==from_hour){
         return(true);
      }   
      else{
         return(false);
      }
   }
   else if(from_hour>to_hour){
      if(japan_time.hour>=from_hour || japan_time.hour < to_hour){
         return(true);
      }
      else{
         return(false);
      }
   }
   
   Print("is_between_time()が機能していない可能性があります。");
   return(false);
   
}

//+------------------------------------------------------------------+
//| Adjust lot with compound interest                                |
//+------------------------------------------------------------------+
bool compound_interest(int base_balance, double& base_lots){
   double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);

   base_lots = base_lots*floor((account_balance/base_balance));
   if(base_lots<0.01){
      base_lots=0.01;
   }
   
   return(true);
}

bool compound_interest(double base_balance, double& base_lots){
   double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);

   base_lots = base_lots*floor((account_balance/base_balance));
   if(base_lots<0.01){
      base_lots=0.01;
   }
   
   return(true);
}


//+------------------------------------------------------------------+
//| MFI signal                                                       |
//+------------------------------------------------------------------+
int sig_mfi(int handle, double buy_line, double sell_line, int index){
   
   /*
   indexの位置を0として
   1の位置のあるろうそくの終値で
   高値圏 -> SElL
   安値圏 -> BUY
   ...............
   
   */
   
   double mfi[];
   int    ret = 0;
   int i      = 0;   
   int size   = 0;

   /*
   CopyBuffer(handle, 0, 1, 6, mfi);
   の時、１本前から、6本前をコピー → ろうそくの位置でいうと、 candle[1] -> mfi[5] candle[2] -> mfi[4] candle[3] -> mfi[3]......
   古いろうそくが、若いindexに格納される
   */
   CopyBuffer(handle, 0, index+1, 1, mfi);
   
   size = ArraySize(mfi);
      
   if(mfi[0]<=buy_line){
      ret = 1;
      //Print("mfi BUY: ", (string)mfi[0]);
   }
   else if(mfi[0]>=sell_line){
      ret = -1;
      //Print("mfi SELL: ", (string)mfi[0]);
   }
   
   return(ret);
   
}


//+------------------------------------------------------------------+
//| Parabolic SAR signal                                             |
//+------------------------------------------------------------------+
int sig_sar(string symbol, double sar_bid, ENUM_TIMEFRAMES timeframes, int handle, int index){
   
   double sar[];
   double open_price = 0;
   double before_op = 0;
   int    ret = 0;
   
   open_price = iOpen(symbol, timeframes, index);
   before_op  = iOpen(symbol, timeframes, index+1);
   CopyBuffer(handle, 0, index, 2, sar);
   
   if((sar[0]>before_op && sar[1]<open_price)){
      ret = -1;
   }
   else if((sar[0]<before_op && sar[1]>open_price)){
      ret = 1;
   }
   
   return(ret);
   
}