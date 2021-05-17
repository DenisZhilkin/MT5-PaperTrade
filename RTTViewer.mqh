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

#define PT_STATE_LEFT     			 (0)
#define PT_STATE_TOP      			 (25)
#define PT_STATE_WIDTH    			 (500)
#define PT_STATE_HEIGHT   			 (300)
#define PT_STATE_PADDING  			 (1)
#define PT_STATE_CAPTION			 "PaperTrade Positions & Orders"
#define PT_STATE_LIST_NAME			 "pt_state_op"

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
    bool AddOrder(string symbol);
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
    StringInit(spacer, 42, 32); // 32 is ANSI space character
    if(!m_list_view.Create(m_chart_id, PT_STATE_LIST_NAME, m_subwin, x1, y1, x2, y2))
        return false;
    if(!Add(m_list_view))
        return false;
    if(!m_list_view.ItemAdd(spacer + "Positions"))
    	return false;
    if(!m_list_view.ItemAdd("Symbol | TimeOpened | B/S | Vol | Price |  S/L  |  T/P  | PnL"))
    	return false; //   USDRUB  22:56:50:123   B     5    74045   73999   75011   1059
    if(!m_list_view.ItemAdd(""))
    	return false;
    if(!m_list_view.ItemAdd(spacer + "Orders"))
    	return false;
   	if(!m_list_view.ItemAdd("Symbol | TimePlaced | B/S | TYPE | Vol | Price |  S/L  |  T/P"))
    	return false;
    return true;
}
/*, datetime time, string dest, string type, long vol, double price, double sl, double tp*/
bool CPTState::AddOrder(string symbol)
{
	string new_order;
	new_order = symbol;
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

