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

class CMenu : public CAppDialog
{

}

class CTestingChart
{

}

class CRTTViewer
{
public:
    static CMenu menu
    static CTestingChart chart
};