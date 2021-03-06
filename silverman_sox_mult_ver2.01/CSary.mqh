//+------------------------------------------------------------------+
//|                                                        CGary.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version "1.03"
#property copyright "jones"
#property link      "https://www.mql5.com"
#property description "silverman_sox_params"

#include "CSilverman_sox.mqh"

/*
パラメータ追加手順
symbol変更
ﾏｼﾞｯｸ変更
パラメータ数変更
パラメータ入力
パラメータ数とGaryの配列要素数を合わせる
*/

input group  "---- 基本設定 ----";
//input string          Currency       = "GOLD.";       //通貨ペア  
//input string          Prefix         = "";  
//input string          Surfix         = "";  
//input int             MAGIC          = 41571075;          //マジックナンバー
//input int             Max_pos        = 5;               //最大ポジション数
input int             Max_spread     = 80;
input int             Slippage       = 10;
//input int             No_entry_min   = 120; 
input bool            Reverse_god    = false;
//input ENUM_TIMEFRAMES Observation_tf = PERIOD_M5;
//      
//input group "---- 決済関連 ----";
//input int    Takeprofit        = 500;            //テイクプロフィット(point)
//input int    Mult_sl           = 5;              //
//input int    Max_sl            = 3000;
//input int    Ts_point          = 500;            //トレーリング利益確保値(point)
//input int    Ts_margin         = 500;            //トレーリングストップロス(point)
//
/*    
input group "---- MFI設定 ----";
input int                 Mfi_period               = 14;          //mfi期間
input int                 Mfi_shift                = 0;           //mfiｸﾛｽ判定のｼﾌﾄ index+2とindex+1でｸﾛｽが起こったか判定
input double              Mfi_difference_from_50   = 20;          //
input ENUM_APPLIED_VOLUME Applied_volume           = VOLUME_TICK; //mfi適用volume
*/
//    
//input group "---- Parabolic SAR設定 ----";
//input int             Sar_shift     = 0;
//input double          Sar_step      = 0.02;
//input double          Sar_maximum   = 0.2;
//input ENUM_TIMEFRAMES Sar_timeframe = PERIOD_H1;      //時間枠
//
input group "---- ﾛｯﾄ関連 ----"
input bool   Compound_interest = false; 
//input double Base_lots    = 0.01;
//input double Base_balance = 100000;

input group  "----エントリー時間設定 ----";
input int    Entry_from_time    = 9;  //エントリー開始時間(0~23)
input int    Entry_to_time      = 3;  //エントリー終了時間(0~23)
input int    Prohibit_entries   = 5;  //現在のバーを0として、N本以内に決済があった場合エントリ不可

input group  "---- discord通知 ----";
input string Webhook_url   = "webhook url";

class Sary{
   /*
   CSilverman_soxのオブジェクト配列を操作するクラス

   */
   private:
   
   public:
      int     sary_size;
      
      Silverman sary[];     //CGoldman_soxのオブジェクト配列
      
      void   Sary(void); //デフォルトコンストラクタ
      void   set_mfi_border(void);
      void   set_points(void);
      void   set_indicator_handles(void);
      void   set_no_entry_min_datetime(void);
      void   set_params_description(void);
      double ticks_to_price(int Ticks, string symbol);
   
};

//+------------------------------------------------------------------+
//| set parameters                                                   |
//+------------------------------------------------------------------+
void Sary::Sary(void){
   
   int i = 0;
   int num_parameter = 5;
   ArrayResize(sary, num_parameter);
   sary_size = num_parameter;
   
   sary[0].magic = 60000;
   
   if(sary_size!=1){
      for(i=1; i<sary_size; i++){
         sary[i].magic = sary[i-1].magic + i;
      }
   }
   
   /*
   sary[0].currency               = Currency;
   sary[0].prefix                 = Prefix;                 
   sary[0].surfix                 = Surfix;              
   sary[0].no_entry_min           = No_entry_min;
   sary[0].max_pos                = Max_pos;
   sary[0].max_sl                 = Max_sl;
   sary[0].observation_timeframe  = Observation_tf;
   sary[0].allow_trade            = true;
   sary[0].reverse_god            = Reverse_god;
   sary[0].compound_interest      = Compound_interest;
   sary[0].base_balance           = Base_balance;
   sary[0].base_lots              = Base_lots;
   sary[0].takeprofit             = Takeprofit;
   sary[0].mult_sl                = Mult_sl;
   sary[0].ts_point               = Ts_point;
   sary[0].ts_margin              = Ts_margin;
   
   sary[0].mfi_period             = Mfi_period;
   sary[0].mfi_shift              = Mfi_shift;
   sary[0].mfi_difference_from_50 = Mfi_difference_from_50;
   sary[0].applied_volume         = Applied_volume;

   sary[0].sar_shift              = Sar_shift;
   sary[0].sar_step               = Sar_step;
   sary[0].sar_maximum            = Sar_maximum;
   sary[0].sar_timeframe          = Sar_timeframe;
   */

   sary[0].currency               = "GOLD.";
   sary[0].prefix                 = "";                 
   sary[0].surfix                 = "";              
   sary[0].no_entry_min           = 360;
   sary[0].max_pos                = 5;
   sary[0].max_sl                 = 3000;
   sary[0].observation_timeframe  = PERIOD_M5;
   sary[0].allow_trade            = true;
   sary[0].reverse_god            = true;
   sary[0].base_balance           = 1000000;
   sary[0].base_lots              = 0.03;
   sary[0].takeprofit             = 750;
   sary[0].mult_sl                = 3;
   sary[0].ts_point               = 780;
   sary[0].ts_margin              = 510;
   sary[0].sar_shift              = 1;
   sary[0].sar_step               = 0.06;
   sary[0].sar_maximum            = 0.2;
   sary[0].sar_timeframe          = PERIOD_H1;


   sary[1].currency               = "CADJPY.";
   sary[1].prefix                 = "";                 
   sary[1].surfix                 = "";              
   sary[1].no_entry_min           = 360;
   sary[1].max_pos                = 5;
   sary[1].max_sl                 = 3000;
   sary[1].observation_timeframe  = PERIOD_M5;
   sary[1].allow_trade            = true;
   sary[1].reverse_god            = true;
   sary[1].base_balance           = 1000000;
   sary[1].base_lots              = 0.03;
   sary[1].takeprofit             = 870;
   sary[1].mult_sl                = 4;
   sary[1].ts_point               = 420;
   sary[1].ts_margin              = 840;
   sary[1].sar_shift              = 6;
   sary[1].sar_step               = 0.02;
   sary[1].sar_maximum            = 0.2;
   sary[1].sar_timeframe          = PERIOD_H1;


   sary[2].currency               = "CADCHF.";
   sary[2].prefix                 = "";                 
   sary[2].surfix                 = "";              
   sary[2].no_entry_min           = 360;
   sary[2].max_pos                = 5;
   sary[2].max_sl                 = 3000;
   sary[2].observation_timeframe  = PERIOD_M5;
   sary[2].allow_trade            = true;
   sary[2].reverse_god            = true;
   sary[2].base_balance           = 1000000;
   sary[2].base_lots              = 0.03;
   sary[2].takeprofit             = 330;
   sary[2].mult_sl                = 8;
   sary[2].ts_point               = 810;
   sary[2].ts_margin              = 360;
   sary[2].sar_shift              = 1;
   sary[2].sar_step               = 0.07;
   sary[2].sar_maximum            = 0.2;
   sary[2].sar_timeframe          = PERIOD_H1;


   sary[3].currency               = "EURCAD.";
   sary[3].prefix                 = "";                 
   sary[3].surfix                 = "";              
   sary[3].no_entry_min           = 360;
   sary[3].max_pos                = 5;
   sary[3].max_sl                 = 3000;
   sary[3].observation_timeframe  = PERIOD_M5;
   sary[3].allow_trade            = true;
   sary[3].reverse_god            = true;
   sary[3].base_balance           = 1000000;
   sary[3].base_lots              = 0.03;
   sary[3].takeprofit             = 900;
   sary[3].mult_sl                = 3;
   sary[3].ts_point               = 300;
   sary[3].ts_margin              = 960;
   sary[3].sar_shift              = 6;
   sary[3].sar_step               = 0.01;
   sary[3].sar_maximum            = 0.2;
   sary[3].sar_timeframe          = PERIOD_H1;


   sary[4].currency               = "CHFJPY.";
   sary[4].prefix                 = "";                 
   sary[4].surfix                 = "";              
   sary[4].no_entry_min           = 360;
   sary[4].max_pos                = 5;
   sary[4].max_sl                 = 3000;
   sary[4].observation_timeframe  = PERIOD_M5;
   sary[4].allow_trade            = true;
   sary[4].reverse_god            = true;
   sary[4].base_balance           = 1000000;
   sary[4].base_lots              = 0.03;
   sary[4].takeprofit             = 360;
   sary[4].mult_sl                = 8;
   sary[4].ts_point               = 900;
   sary[4].ts_margin              = 270;
   sary[4].sar_shift              = 7;
   sary[4].sar_step               = 0.04;
   sary[4].sar_maximum            = 0.2;
   sary[4].sar_timeframe          = PERIOD_H1;

/*
   sary[5].currency               = "";
   sary[5].prefix                 = "";                 
   sary[5].surfix                 = "";              
   sary[5].no_entry_min           = 360;
   sary[5].max_pos                = 5;
   sary[5].max_sl                 = 3000;
   sary[5].observation_timeframe  = PERIOD_M5;
   sary[5].allow_trade            = true;
   sary[5].reverse_god            = true;
   sary[5].base_balance           = 1000000;
   sary[5].base_lots              = 0.01;
   sary[5].takeprofit             = ;
   sary[5].mult_sl                = ;
   sary[5].ts_point               = ;
   sary[5].ts_margin              = ;
   sary[5].sar_shift              = ;
   sary[5].sar_step               = ;
   sary[5].sar_maximum            = 0.2;
   sary[5].sar_timeframe          = PERIOD_H1;

/*
   sary[6].currency               = "";
   sary[6].prefix                 = "";                 
   sary[6].surfix                 = "";              
   sary[6].no_entry_min           = 360;
   sary[6].max_pos                = 5;
   sary[6].max_sl                 = 3000;
   sary[6].observation_timeframe  = PERIOD_M5;
   sary[6].allow_trade            = true;
   sary[6].reverse_god            = true;
   sary[6].base_balance           = 1000000;
   sary[6].base_lots              = 0.01;
   sary[6].takeprofit             = ;
   sary[6].mult_sl                = ;
   sary[6].ts_point               = ;
   sary[6].ts_margin              = ;
   sary[6].sar_shift              = ;
   sary[6].sar_step               = ;
   sary[6].sar_maximum            = 0.2;
   sary[6].sar_timeframe          = PERIOD_H1;

/*
   sary[7].currency               = "";
   sary[7].prefix                 = "";                 
   sary[7].surfix                 = "";              
   sary[7].no_entry_min           = 360;
   sary[7].max_pos                = 5;
   sary[7].max_sl                 = 3000;
   sary[7].observation_timeframe  = PERIOD_M5;
   sary[7].allow_trade            = true;
   sary[7].reverse_god            = true;
   sary[7].base_balance           = 1000000;
   sary[7].base_lots              = 0.01;
   sary[7].takeprofit             = ;
   sary[7].mult_sl                = ;
   sary[7].ts_point               = ;
   sary[7].ts_margin              = ;
   sary[7].sar_shift              = ;
   sary[7].sar_step               = ;
   sary[7].sar_maximum            = 0.2;
   sary[7].sar_timeframe          = PERIOD_H1;

/*
   sary[8].currency               = "";
   sary[8].prefix                 = "";                 
   sary[8].surfix                 = "";              
   sary[8].no_entry_min           = 360;
   sary[8].max_pos                = 5;
   sary[8].max_sl                 = 3000;
   sary[8].observation_timeframe  = PERIOD_M5;
   sary[8].allow_trade            = true;
   sary[8].reverse_god            = true;
   sary[8].base_balance           = 1000000;
   sary[8].base_lots              = 0.01;
   sary[8].takeprofit             = ;
   sary[8].mult_sl                = ;
   sary[8].ts_point               = ;
   sary[8].ts_margin              = ;
   sary[8].sar_shift              = ;
   sary[8].sar_step               = ;
   sary[8].sar_maximum            = 0.2;
   sary[8].sar_timeframe          = PERIOD_H1;

/*
   sary[9].currency               = "";
   sary[9].prefix                 = "";                 
   sary[9].surfix                 = "";              
   sary[9].no_entry_min           = 360;
   sary[9].max_pos                = 5;
   sary[9].max_sl                 = 3000;
   sary[9].observation_timeframe  = PERIOD_M5;
   sary[9].allow_trade            = true;
   sary[9].reverse_god            = true;
   sary[9].base_balance           = 1000000;
   sary[9].base_lots              = 0.01;
   sary[9].takeprofit             = ;
   sary[9].mult_sl                = ;
   sary[9].ts_point               = ;
   sary[9].ts_margin              = ;
   sary[9].sar_shift              = ;
   sary[9].sar_step               = ;
   sary[9].sar_maximum            = 0.2;
   sary[9].sar_timeframe          = PERIOD_H1;

/*
   sary[10].currency               = "";
   sary[10].prefix                 = "";                 
   sary[10].surfix                 = "";              
   sary[10].no_entry_min           = 360;
   sary[10].max_pos                = 5;
   sary[10].max_sl                 = 3000;
   sary[10].observation_timeframe  = PERIOD_M5;
   sary[10].allow_trade            = true;
   sary[10].reverse_god            = true;
   sary[10].base_balance           = 1000000;
   sary[10].base_lots              = 0.01;
   sary[10].takeprofit             = ;
   sary[10].mult_sl                = ;
   sary[10].ts_point               = ;
   sary[10].ts_margin              = ;
   sary[10].sar_shift              = ;
   sary[10].sar_step               = ;
   sary[10].sar_maximum            = 0.2;
   sary[10].sar_timeframe          = PERIOD_H1;

/*
   sary[11].currency               = "";
   sary[11].prefix                 = "";                 
   sary[11].surfix                 = "";              
   sary[11].no_entry_min           = 360;
   sary[11].max_pos                = 5;
   sary[11].max_sl                 = 3000;
   sary[11].observation_timeframe  = PERIOD_M5;
   sary[11].allow_trade            = true;
   sary[11].reverse_god            = true;
   sary[11].base_balance           = 1000000;
   sary[11].base_lots              = 0.01;
   sary[11].takeprofit             = ;
   sary[11].mult_sl                = ;
   sary[11].ts_point               = ;
   sary[11].ts_margin              = ;
   sary[11].sar_shift              = ;
   sary[11].sar_step               = ;
   sary[11].sar_maximum            = 0.2;
   sary[11].sar_timeframe          = PERIOD_H1;

/*
   sary[12].currency               = "";
   sary[12].prefix                 = "";                 
   sary[12].surfix                 = "";              
   sary[12].no_entry_min           = 360;
   sary[12].max_pos                = 5;
   sary[12].max_sl                 = 3000;
   sary[12].observation_timeframe  = PERIOD_M5;
   sary[12].allow_trade            = true;
   sary[12].reverse_god            = true;
   sary[12].base_balance           = 1000000;
   sary[12].base_lots              = 0.01;
   sary[12].takeprofit             = ;
   sary[12].mult_sl                = ;
   sary[12].ts_point               = ;
   sary[12].ts_margin              = ;
   sary[12].sar_shift              = ;
   sary[12].sar_step               = ;
   sary[12].sar_maximum            = 0.2;
   sary[12].sar_timeframe          = PERIOD_H1;

/*
   sary[13].currency               = "";
   sary[13].prefix                 = "";                 
   sary[13].surfix                 = "";              
   sary[13].no_entry_min           = 360;
   sary[13].max_pos                = 5;
   sary[13].max_sl                 = 3000;
   sary[13].observation_timeframe  = PERIOD_M5;
   sary[13].allow_trade            = true;
   sary[13].reverse_god            = true;
   sary[13].base_balance           = 1000000;
   sary[13].base_lots              = 0.01;
   sary[13].takeprofit             = ;
   sary[13].mult_sl                = ;
   sary[13].ts_point               = ;
   sary[13].ts_margin              = ;
   sary[13].sar_shift              = ;
   sary[13].sar_step               = ;
   sary[13].sar_maximum            = 0.2;
   sary[13].sar_timeframe          = PERIOD_H1;

/*
   sary[14].currency               = "";
   sary[14].prefix                 = "";                 
   sary[14].surfix                 = "";              
   sary[14].no_entry_min           = 360;
   sary[14].max_pos                = 5;
   sary[14].max_sl                 = 3000;
   sary[14].observation_timeframe  = PERIOD_M5;
   sary[14].allow_trade            = true;
   sary[14].reverse_god            = true;
   sary[14].base_balance           = 1000000;
   sary[14].base_lots              = 0.01;
   sary[14].takeprofit             = ;
   sary[14].mult_sl                = ;
   sary[14].ts_point               = ;
   sary[14].ts_margin              = ;
   sary[14].sar_shift              = ;
   sary[14].sar_step               = ;
   sary[14].sar_maximum            = 0.2;
   sary[14].sar_timeframe          = PERIOD_H1;

/*
   sary[15].currency               = "";
   sary[15].prefix                 = "";                 
   sary[15].surfix                 = "";              
   sary[15].no_entry_min           = 360;
   sary[15].max_pos                = 5;
   sary[15].max_sl                 = 3000;
   sary[15].observation_timeframe  = PERIOD_M5;
   sary[15].allow_trade            = true;
   sary[15].reverse_god            = true;
   sary[15].base_balance           = 1000000;
   sary[15].base_lots              = 0.01;
   sary[15].takeprofit             = ;
   sary[15].mult_sl                = ;
   sary[15].ts_point               = ;
   sary[15].ts_margin              = ;
   sary[15].sar_shift              = ;
   sary[15].sar_step               = ;
   sary[15].sar_maximum            = 0.2;
   sary[15].sar_timeframe          = PERIOD_H1;

/*
   sary[16].currency               = "";
   sary[16].prefix                 = "";                 
   sary[16].surfix                 = "";              
   sary[16].no_entry_min           = 360;
   sary[16].max_pos                = 5;
   sary[16].max_sl                 = 3000;
   sary[16].observation_timeframe  = PERIOD_M5;
   sary[16].allow_trade            = true;
   sary[16].reverse_god            = true;
   sary[16].base_balance           = 1000000;
   sary[16].base_lots              = 0.01;
   sary[16].takeprofit             = ;
   sary[16].mult_sl                = ;
   sary[16].ts_point               = ;
   sary[16].ts_margin              = ;
   sary[16].sar_shift              = ;
   sary[16].sar_step               = ;
   sary[16].sar_maximum            = 0.2;
   sary[16].sar_timeframe          = PERIOD_H1;

/*
   sary[17].currency               = "";
   sary[17].prefix                 = "";                 
   sary[17].surfix                 = "";              
   sary[17].no_entry_min           = 360;
   sary[17].max_pos                = 5;
   sary[17].max_sl                 = 3000;
   sary[17].observation_timeframe  = PERIOD_M5;
   sary[17].allow_trade            = true;
   sary[17].reverse_god            = true;
   sary[17].base_balance           = 1000000;
   sary[17].base_lots              = 0.01;
   sary[17].takeprofit             = ;
   sary[17].mult_sl                = ;
   sary[17].ts_point               = ;
   sary[17].ts_margin              = ;
   sary[17].sar_shift              = ;
   sary[17].sar_step               = ;
   sary[17].sar_maximum            = 0.2;
   sary[17].sar_timeframe          = PERIOD_H1;

/*
   sary[18].currency               = "";
   sary[18].prefix                 = "";                 
   sary[18].surfix                 = "";              
   sary[18].no_entry_min           = 360;
   sary[18].max_pos                = 5;
   sary[18].max_sl                 = 3000;
   sary[18].observation_timeframe  = PERIOD_M5;
   sary[18].allow_trade            = true;
   sary[18].reverse_god            = true;
   sary[18].base_balance           = 1000000;
   sary[18].base_lots              = 0.01;
   sary[18].takeprofit             = ;
   sary[18].mult_sl                = ;
   sary[18].ts_point               = ;
   sary[18].ts_margin              = ;
   sary[18].sar_shift              = ;
   sary[18].sar_step               = ;
   sary[18].sar_maximum            = 0.2;
   sary[18].sar_timeframe          = PERIOD_H1;

/*
   sary[19].currency               = "";
   sary[19].prefix                 = "";                 
   sary[19].surfix                 = "";              
   sary[19].no_entry_min           = 360;
   sary[19].max_pos                = 5;
   sary[19].max_sl                 = 3000;
   sary[19].observation_timeframe  = PERIOD_M5;
   sary[19].allow_trade            = true;
   sary[19].reverse_god            = true;
   sary[19].base_balance           = 1000000;
   sary[19].base_lots              = 0.01;
   sary[19].takeprofit             = ;
   sary[19].mult_sl                = ;
   sary[19].ts_point               = ;
   sary[19].ts_margin              = ;
   sary[19].sar_shift              = ;
   sary[19].sar_step               = ;
   sary[19].sar_maximum            = 0.2;
   sary[19].sar_timeframe          = PERIOD_H1;

/*
   sary[20].currency               = "";
   sary[20].prefix                 = "";                 
   sary[20].surfix                 = "";              
   sary[20].no_entry_min           = 360;
   sary[20].max_pos                = 5;
   sary[20].max_sl                 = 3000;
   sary[20].observation_timeframe  = PERIOD_M5;
   sary[20].allow_trade            = true;
   sary[20].reverse_god            = true;
   sary[20].base_balance           = 1000000;
   sary[20].base_lots              = 0.01;
   sary[20].takeprofit             = ;
   sary[20].mult_sl                = ;
   sary[20].ts_point               = ;
   sary[20].ts_margin              = ;
   sary[20].sar_shift              = ;
   sary[20].sar_step               = ;
   sary[20].sar_maximum            = 0.2;
   sary[20].sar_timeframe          = PERIOD_H1;

/*
   sary[21].currency               = "";
   sary[21].prefix                 = "";                 
   sary[21].surfix                 = "";              
   sary[21].no_entry_min           = 360;
   sary[21].max_pos                = 5;
   sary[21].max_sl                 = 3000;
   sary[21].observation_timeframe  = PERIOD_M5;
   sary[21].allow_trade            = true;
   sary[21].reverse_god            = true;
   sary[21].base_balance           = 1000000;
   sary[21].base_lots              = 0.01;
   sary[21].takeprofit             = ;
   sary[21].mult_sl                = ;
   sary[21].ts_point               = ;
   sary[21].ts_margin              = ;
   sary[21].sar_shift              = ;
   sary[21].sar_step               = ;
   sary[21].sar_maximum            = 0.2;
   sary[21].sar_timeframe          = PERIOD_H1;

/*
   sary[22].currency               = "";
   sary[22].prefix                 = "";                 
   sary[22].surfix                 = "";              
   sary[22].no_entry_min           = 360;
   sary[22].max_pos                = 5;
   sary[22].max_sl                 = 3000;
   sary[22].observation_timeframe  = PERIOD_M5;
   sary[22].allow_trade            = true;
   sary[22].reverse_god            = true;
   sary[22].base_balance           = 1000000;
   sary[22].base_lots              = 0.01;
   sary[22].takeprofit             = ;
   sary[22].mult_sl                = ;
   sary[22].ts_point               = ;
   sary[22].ts_margin              = ;
   sary[22].sar_shift              = ;
   sary[22].sar_step               = ;
   sary[22].sar_maximum            = 0.2;
   sary[22].sar_timeframe          = PERIOD_H1;

/*
   sary[23].currency               = "";
   sary[23].prefix                 = "";                 
   sary[23].surfix                 = "";              
   sary[23].no_entry_min           = 360;
   sary[23].max_pos                = 5;
   sary[23].max_sl                 = 3000;
   sary[23].observation_timeframe  = PERIOD_M5;
   sary[23].allow_trade            = true;
   sary[23].reverse_god            = true;
   sary[23].base_balance           = 1000000;
   sary[23].base_lots              = 0.01;
   sary[23].takeprofit             = ;
   sary[23].mult_sl                = ;
   sary[23].ts_point               = ;
   sary[23].ts_margin              = ;
   sary[23].sar_shift              = ;
   sary[23].sar_step               = ;
   sary[23].sar_maximum            = 0.2;
   sary[23].sar_timeframe          = PERIOD_H1;

/*
   sary[24].currency               = "";
   sary[24].prefix                 = "";                 
   sary[24].surfix                 = "";              
   sary[24].no_entry_min           = 360;
   sary[24].max_pos                = 5;
   sary[24].max_sl                 = 3000;
   sary[24].observation_timeframe  = PERIOD_M5;
   sary[24].allow_trade            = true;
   sary[24].reverse_god            = true;
   sary[24].base_balance           = 1000000;
   sary[24].base_lots              = 0.01;
   sary[24].takeprofit             = ;
   sary[24].mult_sl                = ;
   sary[24].ts_point               = ;
   sary[24].ts_margin              = ;
   sary[24].sar_shift              = ;
   sary[24].sar_step               = ;
   sary[24].sar_maximum            = 0.2;
   sary[24].sar_timeframe          = PERIOD_H1;

/*
   sary[25].currency               = "";
   sary[25].prefix                 = "";                 
   sary[25].surfix                 = "";              
   sary[25].no_entry_min           = 360;
   sary[25].max_pos                = 5;
   sary[25].max_sl                 = 3000;
   sary[25].observation_timeframe  = PERIOD_M5;
   sary[25].allow_trade            = true;
   sary[25].reverse_god            = true;
   sary[25].base_balance           = 1000000;
   sary[25].base_lots              = 0.01;
   sary[25].takeprofit             = ;
   sary[25].mult_sl                = ;
   sary[25].ts_point               = ;
   sary[25].ts_margin              = ;
   sary[25].sar_shift              = ;
   sary[25].sar_step               = ;
   sary[25].sar_maximum            = 0.2;
   sary[25].sar_timeframe          = PERIOD_H1;

/*
   sary[26].currency               = "";
   sary[26].prefix                 = "";                 
   sary[26].surfix                 = "";              
   sary[26].no_entry_min           = 360;
   sary[26].max_pos                = 5;
   sary[26].max_sl                 = 3000;
   sary[26].observation_timeframe  = PERIOD_M5;
   sary[26].allow_trade            = true;
   sary[26].reverse_god            = true;
   sary[26].base_balance           = 1000000;
   sary[26].base_lots              = 0.01;
   sary[26].takeprofit             = ;
   sary[26].mult_sl                = ;
   sary[26].ts_point               = ;
   sary[26].ts_margin              = ;
   sary[26].sar_shift              = ;
   sary[26].sar_step               = ;
   sary[26].sar_maximum            = 0.2;
   sary[26].sar_timeframe          = PERIOD_H1;

/*
   sary[27].currency               = "";
   sary[27].prefix                 = "";                 
   sary[27].surfix                 = "";              
   sary[27].no_entry_min           = 360;
   sary[27].max_pos                = 5;
   sary[27].max_sl                 = 3000;
   sary[27].observation_timeframe  = PERIOD_M5;
   sary[27].allow_trade            = true;
   sary[27].reverse_god            = true;
   sary[27].base_balance           = 1000000;
   sary[27].base_lots              = 0.01;
   sary[27].takeprofit             = ;
   sary[27].mult_sl                = ;
   sary[27].ts_point               = ;
   sary[27].ts_margin              = ;
   sary[27].sar_shift              = ;
   sary[27].sar_step               = ;
   sary[27].sar_maximum            = 0.2;
   sary[27].sar_timeframe          = PERIOD_H1;
*/
   
   set_mfi_border();
   set_points();
   set_indicator_handles();
   set_no_entry_min_datetime();
   set_params_description();
}


//+------------------------------------------------------------------+
//| set mfi_Buyline & mfi_sellline                                   |
//+------------------------------------------------------------------+
void Sary::set_mfi_border(void){

   int i = 0;
   
   for(i=0; i<sary_size; i++){
      sary[i].buy_line = 50 - sary[i].mfi_difference_from_50;
      sary[i].sell_line = 50 + sary[i].mfi_difference_from_50;
   }
}


//+------------------------------------------------------------------+
//| set points & currency                                            |
//+------------------------------------------------------------------+
void Sary::set_points(void){
   
   int i = 0;
   
   for(i=0; i<sary_size; i++){
      sary[i].ssymbol = sary[i].prefix + sary[i].currency + sary[i].surfix;
      sary[i].ts_price = ticks_to_price(sary[i].ts_point, sary[i].ssymbol);
      sary[i].ts_margin_price = ticks_to_price(sary[i].ts_margin, sary[i].ssymbol);
      sary[i].tp_price = ticks_to_price(sary[i].takeprofit, sary[i].ssymbol);
      
      if(sary[i].takeprofit * sary[i].mult_sl >= sary[i].max_sl){
         sary[i].sl_price = ticks_to_price(sary[i].max_sl, sary[i].ssymbol);
      }
      else{
         sary[i].sl_price = sary[i].ts_price * sary[i].mult_sl;
      }   
   }       

}

//+------------------------------------------------------------------+
//| set indicator handles                                            |
//+------------------------------------------------------------------+
void Sary::set_indicator_handles(void){
   
   int i = 0;
   
   for(i=0; i<sary_size; i++){
      //sary[i].h_mfi = iMFI(sary[i].ssymbol, sary[i].timeframe, sary[i].mfi_period, sary[i].applied_volume);
      sary[i].h_sar = iSAR(sary[i].ssymbol, sary[i].sar_timeframe, sary[i].sar_step, sary[i].sar_maximum);
   }       

}

//+------------------------------------------------------------------+
//| set no_entry_min_datetime                                        |
//+------------------------------------------------------------------+
void Sary::set_no_entry_min_datetime(void){
   
   int i = 0;
   
   for(i=0; i<sary_size; i++){
      sary[i].no_entry_min_datetime = sary[i].no_entry_min*60;
   }       
   
}

//+------------------------------------------------------------------+
//| set parameters description                                       |
//+------------------------------------------------------------------+
void Sary::set_params_description(void){
   
   int i = 0;
   
   for(i=0; i<sary_size; i++){
      sary[i].parms_description = sary[i].ssymbol + ", " + EnumToString(sary[i].sar_timeframe) + ", " +(string)sary[i].reverse_god;
   }
   
}


//+------------------------------------------------------------------+
//| Convert ticks to prices                                          |
//+------------------------------------------------------------------+
double Sary::ticks_to_price(int Ticks, string symbol){
   double price = 0;
   
   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);

   price = Ticks / MathPow(10, digits);
   
   // 価格を有効桁数で丸める
   price = NormalizeDouble(price, digits);
   
   return(price);
}
