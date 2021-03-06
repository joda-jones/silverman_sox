//+------------------------------------------------------------------+
//|                                                     Pos_info.mqh |
//|                                                            jones |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      ""

#include <Trade\PositionInfo.mqh>
#include "MyOrders.mqh"

/*
MyOrdersファイルをincludeする必要があります。

ロング、ショートそれぞれのポジション数や平均コストなどのポジション情報を取得、格納するクラス
主な機能
ポジション数
平均コスト
トレイリングストップ
個別にTP設定
*/


//各ﾎﾟｼﾞｼｮﾝ情報を保管しておくｸﾗｽ
class Each_pos_info{

   private:
   
   public:
      
      //necessary
      string   symbol;
      double   lots;       //          
      double   op;         //
      double   virtual_tp;
      double   virtual_sl;
      double   trailing_sl;
      datetime entry_time; //エントリー時間 datetime
      ulong    ticket;     //
      long     magic;
      bool     close_trigger;
      
      ENUM_POSITION_TYPE type;
      
      void     Each_pos_info(void); //デフォルトコンストラクタ
      
};


//storage virtual_tp, virtual_sl, trailing_sl when set_posinfo
class Strage_virtual_price{

   public:
      double v_tp;
      double v_sl;
      double v_trail_sl;
      ulong  ticket;
      
      void Strage_virtual_price(void);
};


//Each_pos_info[]を操作するクラス
class Each_pos_info_ary{
   
   /*
   OnInit()でset_necessaryを実行
   */
   
   public:
      
      long magic;
      int  slippage;
      bool reverse_god;
      
      int  pos_total;
      
      CPositionInfo mql_posinfo;
      Each_pos_info epi[];
      Strage_virtual_price str_vir_price[];
           
      void Each_pos_info_ary(void);
      
      virtual void set_necessary(long mag, int sli, bool ts_mode);        
      virtual void set_each_pos_info(void);
      virtual void get_long_num(int& ret);
      virtual void get_short_num(int& ret);
      virtual void get_last_entry_time(datetime& ret);
      //virtual int  get_long_num(void);
      //virtual int  get_short_num(void);
      virtual void set_each_virtual_tpsl(void);
      virtual bool ts_from_op(double price, double margin_price);
      virtual bool ts_from_op_reverse(double price, double margin_price);
      virtual bool trailing_stop(double price, double margin_price);
};


//全体のポジション状況を操作するクラス
class Pos_info{
   private:
   
   public:
      
      //necessary
      string symbol;
      int    magic;
      int    slippage;
      
      Each_pos_info_ary epi_ary;
      
      double long_lots;         //ロングの合計ロット          
      double long_price_lots;   //ロングのオープン価格×ロット
      double long_swap;         //ロングのスワップ1
      double long_comi;         //ロングの手数料
      double long_ap;           //ロングの平均コスト
      
      double short_lots;        //ショートの合計ロット
      double short_price_lots;  //ショートのオープン価格×ロット
      double short_swap;        //ショートのスワップ
      double short_comi;        //ショートの手数料
      double short_ap;          //ショートの平均コスto
      
      double new_sl_buy;        //ロングSL
      double new_sl_sell;       //ショートSL
      
      datetime long_last_time;
      datetime short_last_time;
      
      int    long_num;          //ロングのポジション数
      int    short_num;         //ショートのポジション数
      
      bool   reverse_god;       //逆注文ﾓｰﾄﾞ ture->逆注文  false->順注文
      bool   trailing_from_op;  //trueで各OPからトレイリングストップ
      
      ulong  long_ticket[];     //ろんぐのちけっとばんごうかくのう long_tp[]といんでっくすきょうゆ
      ulong  short_ticket[];    //ショートのチケット番号格納
      double long_tp[];         //ろんぐのTPをかくのう
      double short_tp[];        //しょーとのTPをかくのう
      
      void Pos_info(void);                           //デフォルトコンストラクタ
      void Pos_info(string sym, int mag, int sli, bool entry_mode=false, bool trailing_mode=false);   //パラメトリックコンストラクタ
      
      virtual void set_necessary(string sym, int mag, int sli, bool entry_mode=false, bool trailing_mode=false);      //praivateの値をセットする             
      virtual void show_data(void);                                  //クラスメンバを表示する
      virtual void get_array_size(int& long_size, int& short_size);  //ロングショートの配列のサイズを取得する
      virtual bool set_posinfo();                                    //様々なポジション情報を取得する
      virtual bool set_average_price();
      virtual bool set_tp(double tp_range);                          //TP格納する
      virtual bool ts_from_ap(double price, double margin_price);
      virtual bool ts_from_ap_reverse(double price, double margin_price);
      virtual bool ts_from_op(double price, double margin_price);
      virtual bool ts_from_op_reverse(double price, double margin_price);
      virtual bool trailing_stop_from_ap(double ts_point, double ts_margin); //トレイリングストップ
      virtual bool trailing_stop_from_op(double ts_point, double ts_margin); //トレイリングストップ
      virtual bool trailing_stop(double ts_point, double ts_margin);
};



/*
//プッシュ関数
int push(ulong& ary[],ulong val){
	int k2 = 0;
	int len = ArraySize(ary);
	if((len >= 1) && (ary[0] != 0)){
		ArrayResize(ary,(len+1));
		k2 = len;
		ary[k2] = val;
	}
	else if(len==0){
	   ArrayResize(ary,1);
	   ary[0] = val;
	}
	
	return(ArraySize(ary));
}

//プッシュ関数
int push(double& ary[],double val){
	int k2 = 0;
	int len = ArraySize(ary);
	if((len >= 1) && (ary[0] != 0)){
		ArrayResize(ary,(len+1));
		k2 = len;
		ary[k2] = val;
	}
	else if(len==0){
	   ArrayResize(ary,1);
	   ary[0] = val;
	}
	
	return(ArraySize(ary));
}
*/