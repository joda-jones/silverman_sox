//+------------------------------------------------------------------+
//|                                                 CCandle_open.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      "https://www.mql5.com"


class Candle_open{

   private:
   
   public:
      
      string symbol;
      
      datetime time;
      
      ENUM_TIMEFRAMES timeframe;
      
      void Candle_open(void);
      void set_init(string sym, ENUM_TIMEFRAMES tf);
      bool is_candle_open();
   
};

void Candle_open::Candle_open(void){
   
   symbol = "";
   time   = 0;
   
}

void Candle_open::set_init(string sym, ENUM_TIMEFRAMES tf){
   
   symbol = sym;
   time   = iTime(symbol, tf, 0);
   timeframe = tf;
   
}

bool Candle_open::is_candle_open(){
   
   datetime time_0 = iTime(symbol, timeframe, 0);
   if(time_0 != time)
   {
      time = time_0;
      return true;
   }
   return false;
}


class Candle_open_array{
   
   private:
   
   public:
      int         array_size;
      
      Candle_open candle_opens[];
      
      void Candle_open_array(void);
      void set_size(int size);
};

void Candle_open_array::Candle_open_array(void){
   array_size = 0;
}

void Candle_open_array::set_size(int size){
   
   array_size = size;
   ArrayResize(candle_opens, array_size);
   
}

//新規バーのチェック
bool is_new_bar(string symbol, ENUM_TIMEFRAMES tf){
   
   static datetime time = 0;
   if(iTime(symbol, tf, 0) != time)
   {
      time = iTime(symbol, tf, 0);
      return true;
   }
   return false;
}