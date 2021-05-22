//+------------------------------------------------------------------+
//|                                                    RTTViewer.mqh |
//|                                                    Denis Zhilkin |
//|                   https://github.com/DenisZhilkin/RealTimeTester |
//+------------------------------------------------------------------+
#property copyright "Denis Zhilkin"
#property link      "https://github.com/DenisZhilkin/RealTimeTester"
#property version   "1.00"

#include <Controls\Defines.mqh>

#undef  CONTROLS_FONT_NAME
#define CONTROLS_FONT_NAME			 "Consolas"

#include <Controls\Dialog.mqh>
#include <Controls\ListView.mqh>



#define PT_STATE_LEFT     			 (0)
#define PT_STATE_TOP      			 (25)
#define PT_STATE_WIDTH    			 (495)
#define PT_STATE_HEIGHT   			 (300)
#define PT_STATE_PADDING  			 (1)
#define PT_STATE_CAPTION			 "PaperTrade Positions & Orders"
#define PT_STATE_LIST_NAME			 "pt_state_po"
#define PT_SYMBOL_LEN				 (10)
#define PT_VOLUME_LEN				 (3)
#define PT_PRICE_LEN				 (7)

class CPTState : public CAppDialog
{
protected:
    CListView m_list_view;
    uint m_positions_first;
    uint m_positions_last;
    uint m_orders_first;
    uint m_orders_last;
public:
    CPTState() {m_positions_first = NULL; m_positions_last = NULL; m_orders_first = NULL; m_orders_last = NULL;};
    ~CPTState() {};
    
    bool Create(void);
    /*, datetime time, string dest, string type, long vol, double price, double sl, double tp*/
    bool AddOrder(string symbol, string time_placed, string dest, long vol, double price);
    //bool UpdateOrder(string symbol) {};
    //bool RemoveOrder(string symbol) {};
    //bool OpenPosition(string symbol) {};
    //bool UpdatePosition(string symbol) {};
    //bool ClosePosition(string symbol) {};
    //bool UpdateAccount(double m) {};
protected:
    bool CreateListView(void);
};

bool CPTState::Create(void)
{
	int x1 = PT_STATE_LEFT;
    int y1 = PT_STATE_TOP;
    int x2 = PT_STATE_LEFT + PT_STATE_WIDTH;
    int y2 = PT_STATE_TOP + PT_STATE_HEIGHT;
    if(!CAppDialog::Create(0, PT_STATE_CAPTION, 0, x1, y1, x2, y2))
        return false;
    if(!CreateListView())
        return false;
    return true;
}

bool CPTState::CreateListView(void)
{
    int x1 = PT_STATE_PADDING;
    int y1 = PT_STATE_PADDING;
    int x2 = PT_STATE_WIDTH - PT_STATE_PADDING - 8;
    int y2 = PT_STATE_HEIGHT - CONTROLS_DIALOG_CAPTION_HEIGHT - PT_STATE_PADDING - 7;
    string spacer = "";
    StringInit(spacer, 22, 45); // 32 is ANSI space character; 95 is "_"; 45 is "-" 
    if(!m_list_view.Create(m_chart_id, PT_STATE_LIST_NAME, m_subwin, x1, y1, x2, y2))
        return false;
    if(!Add(m_list_view))
        return false;
    if(!m_list_view.ItemAdd(spacer + "Positions"  + spacer))
    	return false;
    if(!m_list_view.ItemAdd("--Symbol--|------Time Opened------|B/S|Vol|--PnL-----"))
    	return false;
    if(!m_list_view.ItemAdd(""))
    	return false;
    StringInit(spacer, 23, 45);
    if(!m_list_view.ItemAdd(spacer + "Orders" + spacer + "-"))
    	return false;
   	if(!m_list_view.ItemAdd("--Symbol--|------Time Placed------|B/S|Vol|--Price---"))
    	return false; //                20.05.2021 19:00:45.572
    return true;
}

bool CPTState::AddOrder(string symbol, string time_placed, string dest, long vol, double price)
{
	string spacer = "";
	int markstofill = PT_SYMBOL_LEN - StringLen(symbol);
	if(markstofill < 0)
	{
		Print("Error: too long symbol name: " + symbol);
		return false;
	}
	StringInit(spacer, markstofill, 32);
	string new_order = symbol + spacer + "|";
	new_order += time_placed + "| ";
	new_order += dest + " |";
	string strvol = (string)vol;
	markstofill = PT_VOLUME_LEN - StringLen(strvol);
	if(markstofill < 0)
	{
		Print("Error: too long volume: " + strvol);
		return false;
	}
	StringInit(spacer, markstofill, 32);
	new_order += spacer + strvol + "|";
	int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	string strprice = DoubleToString(price, digits);
	markstofill = PT_PRICE_LEN - StringLen(strprice);
	if(markstofill < 0)
	{
		Print("Error: too long price: " + strprice);
		return false;
	}
	StringInit(spacer, markstofill, 32);
	new_order += spacer + strprice;
	if(!m_list_view.ItemAdd(new_order))
		return false;
	if(m_orders_first == NULL)
	{
		m_orders_first = 2;
		m_orders_last = 2;
	}
	ChartRedraw();
	return true;
}

/*
class CPTChart
{

};

class CPTBook
{

};


class CPTViewer
{
public:
    CPTState pt_state;
    //CPTChart pt_chart;
};
/**/