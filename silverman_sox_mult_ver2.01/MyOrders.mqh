//+------------------------------------------------------------------+
//|                                                     Pos_info.mqh |
//|                                                            jones |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      ""

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

CTrade m_trade;

uint MyOrderWaitingTime = 3;              //オーダー送信に失敗した際の待機時間(秒)

/*
ロング、ショートそれぞれのポジション数や平均コストなどのポジション情報を取得、格納するクラス
主な機能
ポジション数
平均コスト
トレイリングストップ
個別にTP設定
*/

//+------------------------------------------------------------------+
//| オーダーセンド関数 　　　　　　　　　　　　　　　　                                   |
//+------------------------------------------------------------------+
bool MyOrderSend(MqlTradeRequest& request, MqlTradeResult& result){
   if(OrderSend(request,result)){
      if(result.retcode == TRADE_RETCODE_DONE){
         Print(request.symbol + (string)request.type +" TRADE_RETCODE_DONE ");
         return(true);
      }
      else{
         Print("retcode : ",result.retcode);
         return(false);
         //Alert("エラーが発生しました。エキスパートをチャートからアンロードします");
         //ExpertRemove();
      }
   }
   else{
      Print("OrderSendEroor : ",GetLastError());
      return(false);
      //Alert("エラーが発生しました。エキスパートをチャートからアンロードします");
      //ExpertRemove();
   }
}


//オーダークローズ関数
bool MyOrderClose(int slippage, ulong ticket)
{
   uint starttime = GetTickCount();
   while(true)
   {
      if(GetTickCount() - starttime > MyOrderWaitingTime*1000)
      {
         Alert("OrderClose timeout. Check the experts log.");
         return(false);
      }

      m_trade.PositionClose(ticket,slippage);
      //Print("#########################close by MyOrders.mqh###################################");
      if(!PositionSelectByTicket(ticket))return(true);
      int err = GetLastError();
      Print("[OrderCloseError] : ", err);
      Sleep(100);
   }
   return(false);
}

