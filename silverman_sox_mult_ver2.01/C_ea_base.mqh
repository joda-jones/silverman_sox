//+------------------------------------------------------------------+
//|                                                    C_ea_base.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      "https://www.mql5.com"
#property version   "1.00"

// マクロ定義
#define  BUY   1
#define  SELL -1

class C_ea_base{
   private:
   
   public:
      string ea_name;
      bool   compound_interest;
      double base_balance;
      double base_lots;
      double entry_lots;
      int    from_hour;
      int    to_hour;
      
      void     C_ea_base(void);
      double   ticks_to_price(double ticks, string symbol); 
      bool     compound_interest_method();
      bool     is_between_time();
      bool     GetTradeHistory(int days);
      bool     GetLastOrderTicket(ulong& array[]);
      datetime Get_last_open(int magic_number=0);
      datetime Get_last_close(int magic_number=0);
      double   Get_last_profit(int magic_number=0);
      int      Get_last_consecutive_defeats(int magic_number=0);
      
};


void C_ea_base::C_ea_base(void){
   ea_name           = MQLInfoString(MQL_PROGRAM_NAME);
   compound_interest = false;
   base_balance      = 1000000;
   base_lots         = 0.01;
   entry_lots        = base_lots;
   from_hour         = 16;
   to_hour           = 2;
}


double C_ea_base::ticks_to_price(double ticks, string symbol){
   double price = 0;
   
   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   price = ticks / MathPow(10, digits);
   
   // 価格を有効桁数で丸める
   price = NormalizeDouble(price, digits);
   
   return(price);
}

//+------------------------------------------------------------------+
//|compound_interest                                                 |
//+------------------------------------------------------------------+

bool C_ea_base::compound_interest_method(){
   double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double account_credit  = AccountInfoDouble(ACCOUNT_CREDIT);
   
   entry_lots = base_lots*floor(((account_equity+account_credit)/base_balance));
   if(entry_lots<0.01){
      entry_lots=0.01;
   }
   
   return(true);
}


//+------------------------------------------------------------------+
//| Judge of entry time                                              |
//+------------------------------------------------------------------+
bool C_ea_base::is_between_time(){
   
   /*
   日本時間(hour)が、 from_time ~ to_time の中に含まれる  --> true 
   日本時間(hour)が、 from_time ~ to_time の中に含まれない --> false
   
   ※from_time=10, to_time=12の時のtrue判定になる時間
     -->10時～11時59分59.9999999.......秒まで 12時になった瞬間falseを返す。
   
   ※from_time == to_timeの時
      →from_time 時のときにtrue 
   
   以下の記述をすることを推奨
   if(from_hour<0 || from_hour>24 || to_hour<0 || to_hour>24){
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
//| Function to get the time of the last closed order                |
//+------------------------------------------------------------------+
bool C_ea_base::GetTradeHistory(int days){
   /*
   過去days日の履歴をリクエストし、障害が発生した場合にはfalseを返す
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

bool C_ea_base::GetLastOrderTicket(ulong& array[]){
   /*
   過去20日の取引をリクエストする。
   注文が存在した場合、ticketを配列に渡す。
   */
   
   if(!GetTradeHistory(20)){
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


datetime C_ea_base::Get_last_open(int magic_number=0){
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
      if(deal_entry==DEAL_ENTRY_IN && deal_magic==magic_number){
         if(ret<HistoryDealGetInteger(deal_tickets[i], DEAL_TIME)){
            HistoryDealGetInteger(deal_tickets[i], DEAL_TIME, ret);
         }
      }
   }   
   
   return(ret);  
}

datetime C_ea_base::Get_last_close(int magic_number=0){
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
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==magic_number){
         if(ret<HistoryDealGetInteger(deal_tickets[i], DEAL_TIME)){
            HistoryDealGetInteger(deal_tickets[i], DEAL_TIME, ret);
         }
      }
   }   
   
   return(ret);  
}

double C_ea_base::Get_last_profit(int magic_number=0){
   /*
   最後に決済したオーダーの決済損益を渡す。
   DEAL_ENTRY_OUTのdealがない場合、0を返す.
   */
   
   double   ret        = 0;
   datetime exit_time  = 0;
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
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==magic_number){
         if(exit_time<HistoryDealGetInteger(deal_tickets[i], DEAL_TIME)){
            HistoryDealGetInteger(deal_tickets[i], DEAL_TIME, exit_time);
            HistoryDealGetDouble(deal_tickets[i], DEAL_PROFIT, ret);
         }
      }
   }   
   
   return(ret);  
}

int C_ea_base::Get_last_consecutive_defeats(int magic_number=0){
   /*
   直近の連敗数を返す。
   DEAL_ENTRY_OUTのdealがない場合、0を返す.
   */
   
   int      ret         = 0;
   double   last_profit = 0;  
   datetime exit_time   = 0;
   int      array_size  = 0;
   int      i           = 0;
   long     deal_magic  = 0;
   ulong    deal_tickets[];
   ulong    deal_entry;
   string   com         = "";
   
   //deal_tickets[]にdealのチケットを渡す。
   GetLastOrderTicket(deal_tickets);
   ArraySort(deal_tickets);
   array_size = ArraySize(deal_tickets);
   
   //deal_tickets[]のサイズが0の時、0を返す。
   if(array_size==0){
      return(ret);
   }
   
   //forループでdeal_ticket[]の中身を確認
   //DEAL_ENTRY_OUTだった場合、より時刻が後のものを返す.
   for(i=array_size-1; i>=0; i--){
      HistoryDealGetInteger(deal_tickets[i], DEAL_ENTRY, deal_entry);
      HistoryDealGetInteger(deal_tickets[i], DEAL_MAGIC, deal_magic);
      if(deal_entry==DEAL_ENTRY_OUT && deal_magic==magic_number){
         if(exit_time>HistoryDealGetInteger(deal_tickets[i], DEAL_TIME) || exit_time==0 ){
            HistoryDealGetInteger(deal_tickets[i], DEAL_TIME, exit_time);
            HistoryDealGetDouble(deal_tickets[i], DEAL_PROFIT, last_profit);
            
            if(last_profit<0){
               ret++;
            }
            else{
               break;
            }
            
         }
      }
   }   
   
   return(ret);  
}