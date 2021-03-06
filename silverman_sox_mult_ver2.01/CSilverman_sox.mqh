//+------------------------------------------------------------------+
//|                                                 CGoldman_sox.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      "https://www.mql5.com"

#include "C_ea_base.mqh"

class Silverman : public C_ea_base{
   private:
   
   public:
      //"---- 基本設定 ----";
      string          currency;       //通貨ペア  
      string          prefix;  
      string          surfix;
      string          parms_description;  
      int             no_entry_min;
      int             magic;          //マジックナンバー
      int             max_pos;        //最大ポジション数
      ENUM_TIMEFRAMES observation_timeframe;      //時間枠
      bool            allow_trade;
      bool            reverse_god;
      
      //"---- 決済関連 ----";
      int    takeprofit;          //テイクプロフィット(point)
      int    mult_sl;
      int    max_sl;
      int    stoploss;            //ストップロス(point)
      int    ts_point;            //トレーリング利益確保値(point)
      int    ts_margin;           //トレーリングストップロス(point)
      
      //"---- MFI設定 ----";
      int                 mfi_period;             //mfi期間
      int                 mfi_shift;              //mfiｸﾛｽ判定のｼﾌﾄ index+2とindex+1でｸﾛｽが起こったか判定
      double              mfi_difference_from_50;  //
      double              buy_line;               //買いﾗｲﾝ
      double              sell_line;              //売りﾗｲﾝ
      ENUM_APPLIED_VOLUME applied_volume;         //mfi適用volume
      
      //"---- Parabolic SAR設定 ----";
      double          sar_step;
      double          sar_maximum;
      int             sar_shift;
      ENUM_TIMEFRAMES sar_timeframe;
      
      //"---- インジケーターハンドル ----";
      int h_mfi;
      int h_sar;
      
      //"---- その他変数 ----";
      string       ssymbol;
      double       ts_price;  //
      double       ts_margin_price;  //
      double       tp_price;
      double       sl_price;
      datetime     no_entry_min_datetime;
      
      //"---- メソッド ----";
      void Silverman(void);  //デフォルトコンストラクタ
   
};

void Silverman::Silverman(void){

   C_ea_base();
   /*
   ea_name           = MQLInfoString(MQL_PROGRAM_NAME);
   compound_interest = false;
   base_balance      = 1000000;
   base_lots         = 0.01;
   entry_lots        = base_lots;
   from_hour         = 16;
   to_hour           = 2;
   */
   
   //"---- 基本設定 ----";
   currency              = "";                 //通貨ペア  
   prefix                = "";                 
   surfix                = "";    
   parms_description     = "";             
   no_entry_min          = 0;
   magic                 = 0;                  //マジックナンバー
   max_pos               = 0;
   observation_timeframe = PERIOD_D1;          //時間枠
   allow_trade           = true;
   reverse_god           = false;
   
   //"---- 決済関連 ----";
   takeprofit = 0;          //テイクプロフィット(point)
   stoploss   = 0;            //ストップロス(point)
   mult_sl    = 0;
   ts_point   = 0;            //トレーリング利益確保値(point)
   ts_margin  = 0;           //トレーリングストップロス(point)
   
   //"---- MFI設定 ----";
   mfi_period     = 0;     //mfi期間
   mfi_shift      = 0; //mfiｸﾛｽ判定のｼﾌﾄ index+2とindex+1でｸﾛｽが起こったか判定
   buy_line       = 0; //買いﾗｲﾝ
   sell_line      = 0; //売りﾗｲﾝ
   applied_volume = VOLUME_TICK; //mfi適用volume
   
   //"---- Parabolic SAR設定 ----";
   sar_shift     = 0;
   sar_step      = 0;
   sar_maximum   = 0;
   sar_timeframe = PERIOD_H1;
   
   //"---- インジケーターハンドル ----";
   h_mfi = 0;
   h_sar = 0;
   
   //"---- その他変数 ----";
   ssymbol               = "";
   ts_price              = 0;  //
   ts_margin_price       = 0;  //
   tp_price              = 0;
   sl_price              = 0;
   no_entry_min_datetime = 0;
}

