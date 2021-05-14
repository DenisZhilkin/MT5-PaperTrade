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

class CPTState : public CAppDialog
{
protected:
    CListView list_view;
public:
    CPTState() {};
    ~CPTState() {};

    virtual bool Create(void);

protected:
    bool CreateListView(void);
};

bool CPTState::Create(void)
{
	int x1 = PT_STATE_LEFT;
    int y1 = PT_STATE_TOP;
    int x2 = PT_STATE_LEFT + PT_STATE_WIDTH;
    int y2 = PT_STATE_TOP + PT_STATE_HEIGHT;
    if(!CAppDialog::Create(0, "PaperTrade Orders & Positions", 0, x1, y1, x2, y2))
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
    if(!list_view.Create(m_chart_id, "RTT_OP", m_subwin, x1, y1, x2, y2))
        return false;
    if(!Add(list_view))
        return false;
    if(!list_view.AddItem("Symbol | TimeOpened | B/S | Vol | Price |  S/L  |  T/P  | PnL"))
    	return(false); //  USDRUB  22:56:50:123   B     5    74045   73999   75011   1059
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
    CPTChart pt_chart;
};
/**/

