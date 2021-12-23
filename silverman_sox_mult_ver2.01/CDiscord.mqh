//+------------------------------------------------------------------+
//|                                                 send_discode.mqh |
//|                                                            jones |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jones"
#property link      "https://www.mql5.com"


class CDiscord{
   
   private:
   
   public:
      string url;
      
      void discord(void);
      void init(string webhook_url);
      bool send_discord(string msg);
   
};

void CDiscord::discord(void){
   Print("A 'discord' instance has been created.");
}

void CDiscord::init(string webhook_url){
   url = webhook_url;
}


//SendDiscord
bool CDiscord::send_discord(string msg){
   string method = "GET";
   int status_code;
   string result_headers;
   char data[];
   char result[];
   if (msg != NULL ){
      StringToCharArray("content=" + msg, data, 0, WHOLE_ARRAY, CP_UTF8);
      method = "POST";
   }
   status_code = WebRequest(method, url, NULL, NULL, 3000, data, 0, result, result_headers);
   printf("Webhook Status Code : %d(%s)", status_code, method);
   if (status_code == -1){
      Print(GetLastError());
      return(false);
   }else if(status_code != 200 && status_code != 204){
      return(false);
   }
   return(true);
}
