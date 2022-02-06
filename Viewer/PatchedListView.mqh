//+------------------------------------------------------------------+
//|                                              PatchedListView.mqh |
//|                                                    Denis Zhilkin |
//|                   https://github.com/DenisZhilkin/RealTimeTester |
//|                                                                  |
//|    Patch of Controls\ListView::ItemDelete()                      |
//|    NOTE: The most code of this method is produced by             |
//|                                       MetaQuotes Software Corp.  |
//|    To provide correctness to my product - MT5-PaperTrade I had   |
//|    to add few code lines to this method, which are marked by     |
//|    comment lines with "Patch" label                              |
//|    Pathed Bug: scrollbar disapears to early, while ListView      |
//|    still has some items outside visible area                     |
//+------------------------------------------------------------------+
#property copyright "Denis Zhilkin"
#property link      "https://github.com/DenisZhilkin/RealTimeTester"
#property version   "1.00"

#define private protected
#include <Controls\ListView.mqh>
#undef private


class CPatchedListView : public CListView
{
public:
    CPatchedListView() {};
    ~CPatchedListView() {};
    
    virtual bool ItemDelete(const int index);
};

//+------------------------------------------------------------------+
//| Delete item (row)                                                |
//+------------------------------------------------------------------+
bool CPatchedListView::ItemDelete(const int index)
{
//--- delete
   if(!m_strings.Delete(index))
      return(false);
   if(!m_values.Delete(index))
      return(false);
//--- number of items
   int total=m_strings.Total();
//--- exit if number of items does not exceed the size of visible area
   if(total<m_total_view)
     {
      if(m_height_variable && total!=0)
        {
         Height(total*m_item_height+2*CONTROLS_BORDER_WIDTH);
         m_rows[total].Hide();
        }
      return(Redraw());
     }
//--- if number of items exceeded the size of visible area
   if(total==m_total_view)
     {

      //-------------------Patch---------------------
      // move to the top of the list
      m_offset = 0;
      //---------------------------------------------
      
      //--- disable vertical scrollbar
      if(!VScrolled(false))
         return(false);
      //--- and immediately make it unvisible
      if(!OnVScrollHide())
         return(false);
     }

//-----------------------Patch-----------------------
    int off_index = total - m_total_view;
    if(total > m_total_view && m_current > off_index)
    {
      if(m_offset > off_index)
         m_offset = off_index;
    }
//---------------------------------------------------

//--- set up the scrollbar
   m_scroll_v.MaxPos(m_strings.Total()-m_total_view);
//--- redraw
   return(Redraw());
}