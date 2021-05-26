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
#define CONTROLS_FONT_NAME          "Consolas"

#include <Controls\Dialog.mqh>
#include <Controls\ListView.mqh>

#define PT_STATE_LEFT                (0)
#define PT_STATE_TOP                 (25)
#define PT_STATE_WIDTH               (515)
#define PT_STATE_HEIGHT              (300)
#define PT_STATE_PADDING             (1)
#define PT_STATE_CAPTION             "PaperTrade Positions & Orders"
#define PT_STATE_LIST_NAME           "pt_state_po"
#define PT_STATE_SYMBOL_LEN          (10)
#define PT_STATE_TIME_LEN            (23)
#define PT_STATE_BS_LEN              (3)
#define PT_STATE_VOLUME_LEN          (3)
#define PT_STATE_LASTCOL_LEN         (10)
#define PT_STATE_ORDERS_INDEX        (5) // initial m_orders_first = m_orders_last
#define PT_STATE_POSITIONS_INDEX     (3) // initial m_positions_first = m_positions_last

class CPTState : public CAppDialog
{
protected:
    CListView m_list_view;
    int m_positions_first;
    int m_positions_last;
    int m_orders_first;
    int m_orders_last;
public:
    CPTState() : m_positions_first(-1),
                 m_positions_last(-1),
                 m_orders_first(-1),
                 m_orders_last(-1)
    {};
    ~CPTState() {};
    
    bool Create(void);
    bool AddOrder(string symbol, string time_placed, string dest, long vol, double price);
    //bool UpdateOrder(string symbol) {};
    //bool RemoveOrder(string symbol) {};
    bool AddPosition(string symbol, string time_opened, string dest, long vol, double pnl);
    bool UpdatePosition(int index, double new_pnl, long new_vol);
    //bool RemovePosition(string symbol) {};
    bool UpdateAccount(double balance, double equity, double freemargin);
protected:
    bool CreateListView(void);
    bool BuildCommonCols(string symbol, string time_placed, string dest, long vol, string& colstring);
    bool NormalizeField(string& field, int len);
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
     
    if(!m_list_view.Create(m_chart_id, PT_STATE_LIST_NAME, m_subwin, x1, y1, x2, y2))
        return false;
    if(!Add(m_list_view))
        return false;
    if(!m_list_view.ItemAdd("Balance: - Equity: - Free: -"))
        return false;
    string spacer = "";
    StringInit(spacer, 22, 45); // 32 is ANSI space character; 95 is "_"; 45 is "-"
    if(!m_list_view.ItemAdd(spacer + "Positions"  + spacer))
        return false;
    if(!m_list_view.ItemAdd("--Symbol--|------Time Opened------|B/S|Vol|---PnL----"))
        return false;
    StringInit(spacer, 23, 45);
    if(!m_list_view.ItemAdd(spacer + "Orders" + spacer + "-"))
        return false;
    if(!m_list_view.ItemAdd("--Symbol--|------Time Placed------|B/S|Vol|--Price---"))
        return false;
    return true;
}

bool CPTState::UpdateAccount(double balance, double equity, double freemargin)
{
    string account = "Balance: " + DoubleToString(balance, 2) + " Equity: " +
    DoubleToString(equity, 2) + " Free: " + DoubleToString(freemargin, 2);
    if(!m_list_view.ItemUpdate(0, account))
        return false;
    return true;
}

bool CPTState::BuildCommonCols(string symbol, string time, string dest, long vol, string& colstring)
{
    string spacer = "";
    int markstofill = PT_STATE_SYMBOL_LEN - StringLen(symbol);
    if(markstofill < 0)
    {
        Print("Error: too long symbol name: " + symbol);
        return false;
    }
    StringInit(spacer, markstofill, 32);
    colstring = symbol + spacer + "|";
    colstring += time + "| ";
    colstring += dest + " |";
    string strvol = (string)vol;
    markstofill = PT_STATE_VOLUME_LEN- StringLen(strvol);
    if(markstofill < 0)
    {
        Print("Error: too long volume: " + strvol);
        return false;
    }
    StringInit(spacer, markstofill, 32);
    colstring += spacer + strvol + "|";
    return true;
}

bool CPTState::NormalizeField(string& field, int len)
{
    int markstofill = len - StringLen(field);
    if(markstofill < 0)
    {
        Print("Error: too long field: " + field);
        return false;
    }
    string spacer = "";
    StringInit(spacer, markstofill, 32);
    field = spacer + field;
    return true;
}

bool CPTState::AddPosition(string symbol, string time_opened, string dest, long vol, double pnl)
{
    string new_position = "";
    if(!BuildCommonCols(symbol, time_opened, dest, vol, new_position))
        return false;
    string strpnl = DoubleToString(pnl, 2);
    string spacer = "";
    int markstofill = PT_STATE_LASTCOL_LEN - StringLen(strpnl);
    if(markstofill < 0)
    {
        Print("Error: too long PnL: " + strpnl);
        return false;
    }
    StringInit(spacer, markstofill, 32);
    new_position += spacer + strpnl;
    int index;
    if(m_positions_first < 0)
    {
        index = PT_STATE_POSITIONS_INDEX;
    }
    else
    {
        index = m_positions_last + 1;
    }
    if(!m_list_view.ItemInsert(index, new_position))
        return false;
    if(!(m_positions_first < 0))
    {
        m_positions_last++;
    }
    else
    {
        m_positions_first = PT_STATE_POSITIONS_INDEX;
        m_positions_last = PT_STATE_POSITIONS_INDEX;
    }
    if(m_orders_first < 0)
    {
        m_orders_first = PT_STATE_ORDERS_INDEX;
        m_orders_last = PT_STATE_ORDERS_INDEX; 
    }
    m_orders_first++;
    m_orders_last++;
    ChartRedraw();
    return true;
}

bool CPTState::UpdatePosition(int index, double new_pnl, long new_vol=NULL)
{
    if(m_positions_first < 0) return false;
    index += m_positions_first;
    if(index < m_positions_first || index > m_positions_last)
    {
        // log
        return false;
    }
    if(!m_list_view.Select(index)) return false;
    string row = m_list_view.Select();
    int edge = PT_STATE_SYMBOL_LEN + PT_STATE_TIME_LEN + PT_STATE_BS_LEN + 3; // 3{|}
    if(new_vol != NULL)
    {
        row = StringSubstr(row, 0, edge);
        string strvol = (string)new_vol;
        NormalizeField(strvol, PT_STATE_VOLUME_LEN);
        row += strvol + "|";
    }
    else
    {
        row = StringSubstr(row, 0, edge + PT_STATE_VOLUME_LEN + 1);
    }
    string strpnl = DoubleToString(new_pnl, 2);
    NormalizeField(strpnl, PT_STATE_LASTCOL_LEN);
    row += strpnl;
    if(!m_list_view.ItemUpdate(index, row))
        return false;
    ChartRedraw();
    return true;
}

bool CPTState::AddOrder(string symbol, string time_placed, string dest, long vol, double price)
{
    string new_order = "";
    if(!BuildCommonCols(symbol, time_placed, dest, vol, new_order))
        return false;
    string spacer = "";
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    string strprice = DoubleToString(price, digits);
    int markstofill = PT_STATE_LASTCOL_LEN - StringLen(strprice);
    if(markstofill < 0)
    {
        Print("Error: too long price: " + strprice);
        return false;
    }
    StringInit(spacer, markstofill, 32);
    new_order += spacer + strprice;
    if(!m_list_view.ItemAdd(new_order))
        return false;
    if(m_orders_first < 0)
    {
        m_orders_last++;
    }
    else
    {
        m_orders_first = PT_STATE_ORDERS_INDEX;
        m_orders_last = PT_STATE_ORDERS_INDEX;
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