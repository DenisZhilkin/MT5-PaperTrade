//+------------------------------------------------------------------+
//|                                                    RTTViewer.mqh |
//|                                                    Denis Zhilkin |
//|                   https://github.com/DenisZhilkin/RealTimeTester |
//+------------------------------------------------------------------+
#property copyright "Denis Zhilkin"
#property link      "https://github.com/DenisZhilkin/RealTimeTester"
#property version   "1.00"

#include <Controls\Dialog.mqh>
#include <Controls\ListView.mqh>

#define TRADING_STATE_LEFT      (5)
#define TRADING_STATE_TOP       (15)
#define TRADING_STATE_WIDTH     (350)
#define TRADING_STATE_HEIGHT    (50)
#define TRADING_STATE_PADDING   (5)
;
class CTradingState : public CAppDialog
{
public:
    int a;

protected:
    string message;
    CListView list_view;

public:
    CTradingState()
    {
        message = "Hello! I`m a Menu!";
    }

    bool Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
    {
        // int x1 = TRADING_STATE_LEFT;
        // int y1 = TRADING_STATE_TOP;
        // int x2 = TRADING_STATE_LEFT + TRADING_STATE_WIDTH;
        // int y2 = TRADING_STATE_TOP + TRADING_STATE_HEIGHT;
        if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
            return false;
        if(!CreateListView())
            return false;
        return true;
    }

    void PrintMessage()
    {
        Alert(message);
    }

protected:
    bool CreateListView()
    {
        int x1 = TRADING_STATE_LEFT + TRADING_STATE_PADDING;
        int y1 = TRADING_STATE_TOP + TRADING_STATE_PADDING;
        int x2 = TRADING_STATE_LEFT + TRADING_STATE_WIDTH - TRADING_STATE_PADDING;
        int y2 = TRADING_STATE_TOP + TRADING_STATE_HEIGHT - TRADING_STATE_PADDING;
        if(!list_view.Create(0, "TradingState_OrdersPositions", 0, x1, y1, x2, y2))
            return false;
        if(!Add(list_view))
            return false;
        return true;
    }
};

class CProfitChart
{

};

class CRTTViewer
{
public:
    CTradingState trading_state;
    CProfitChart profit_chart;
};