//+------------------------------------------------------------------+
//|                                               RealTimeTester.mqh |
//|                                                    Denis Zhilkin |
//|                   https://github.com/DenisZhilkin/RealTimeTester |
//+------------------------------------------------------------------+
#property copyright "Denis Zhilkin"
#property link      "https://github.com/DenisZhilkin/RealTimeTester"
#property version   "1.00"

enum ENUM_DESTINATION {B, S};

class COrder
{
protected:
    string             symbol;
    ENUM_DESTINATION   destination;
    ulong              volume;
    double             price, sl, tp;
    bool               accepted;
    double             epsilon;
    long               last_tick_time;

public:
    COrder()
    {
        accepted = false;
    };

    virtual ulong UpdateExecution(MqlBookInfo &book, MqlTick &tick) {return 0;};
    
protected:   
    bool Init(string _symbol=NULL, ENUM_DESTINATION _destination, ulong _volume, double _sl=NULL, double _tp=NULL)
    {
        if(_symbol == NULL)
            symbol  = _Symbol;
        else   
            symbol  = _symbol;
        
        destination = _destination;
        volume      = _volume;
        if(!CheckSlTp(_sl, _tp)) return false;
        sl          = _sl;
        tp          = _tp;
        epsilon     = 1.0 / pow(10, SymbolInfoInteger(symbol, SYMBOL_DIGITS) + 1);
        return true;
    };
    
    bool CheckSlTp(double &_price, double &_sl, double &_tp)
    {
        if(_price == NULL) _price = price;
        if(_sl == NULL) _sl = sl;
        if(_tp == NULL) _tp = tp;
        if (destination == B)
            return (_sl == NULL || _sl < _price) || (_tp == NULL || _tp > _price);
        else
            return (_sl == NULL || _sl > _price) || (_tp == NULL || _tp < _price);
    };
};

class CLimitOrder : public COrder
{
protected:
    ulong  frontvolume;
    double pricestep;
public:
    CLimitOrder(string _symbol=NULL, ENUM_DESTINATION _destination=B, double _price=NULL, ulong _volume=1, double _sl=NULL, double _tp=NULL)
    {
        if( !Init(_symbol, _destination, _volume, _sl, _tp) ) return;
        MqlBookInfo book[];
        MarketBookGet(symbol, book);
        pricestep = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        if(_price == NULL)
        {
            if(destination == B) price = book[20].price;
            else if(destination == S) price = book[19].price;
        }
        else price = _price;
        // check price step
        double x = price / pricestep;
        if((x - floor(x)) > epsilon) return;
        // check price
        if((destination == B && price > (book[19].price - epsilon)) || (destination == S && price < (book[20].price + epsilon))) return;
        // get frontvolume
        frontvolume = NULL;
        UpdateFrontvolume(book);
        accepted = true;
    };
    
    bool Modify(double new_price=NULL, double new_sl=NULL, double new_tp=NULL)
    {
        if(accepted) return false;
        if(!CheckSlTp(new_price, new_sl, new_tp)) return false;
        price = new_price;
        sl = new_sl;
        tp = new_tp;
        return true;
    };
    // return volume executed at this iteration
    ulong UpdateExecution(MqlBookInfo &book, MqlTick &tick) override
    {
        if(tick.time_msc == last_tick_time) return;
        last_tick_time = tick.time_msc;
        UpdateFrontvolume(book);
        ulong executed = 0;
        if(MathAbs(tick.last - price) < epsilon)
        {
            if(frontvolume >= tick.volume)
                frontvolume -= tick.volume;
            else
            {
                ulong overfrontvol = tick.volume - frontvolume;
                frontvolume = 0;
                if(volume > overfrontvol)
                {
                    executed = overfrontvol; 
                    volume -= executed;
                }
                else
                {
                    executed = volume;
                    volume = 0;
                }
            }
        }
        return executed;
    };

protected:
    void UpdateFrontvolume(MqlBookInfo &book)
    {
        int booksize = ArraySize(book);
        ulong vol_at_price = 0;
        for(int i=0; i<booksize; i++)
            if(MathAbs(price - book[i].price) < epsilon)
            {
                vol_at_price = book[i].volume;
                break;
            }
        if(frontvolume == NULL || vol_at_price < frontvolume)
            frontvolume = vol_at_price;
    }
};

class CPosition
{
public:
    string           symbol;
    ENUM_DESTINATION destination;
    ulong            volume;
    double           price, sl, tp;
    double           profit;
    datetime         timeopened, timeclosed;
    
    CPosition(COrder &order)
    {
        symbol      = order.symbol;
        destination = order.destination;
        volume      = order.volume;
        price       = order.price;
        sl          = order.sl;
        tp          = order.tp;
    };
    
    bool Modify(double new_sl, double new_tp)
    {
        return false;
    };
};

class RealTimeTester
{
public: // protected:
    COrder    orders[], orders_history[];
    CPosition positions[], positions_history[];
    string    symbol;
    int       positions_total;
    double    bestask, bestbid, spread;
    double    pricestep;
    long      last_tick_time;

public:
    RealTimeTester(string _symbol=NULL)
    {
        if(symbol == NULL) symbol = _Symbol;
        pricestep = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    };
    
    ~RealTimeTester()
    {
        // delete all orders and positions
    }
    
    void Update(MqlTick &tick)
    {
        if(tick.time_msc == last_tick_time) return;
        last_tick_time = tick.time_msc;
        bestask = tick.ask;
        bestbid = tick.bid;
        spread  = bestask - bestbid;
        
        // Обработка позиций: проверка, закрытие готовых

        // Обработка ордеров: проверка, преобразование в позиции
        
    };
    
    void BLim(double price=NULL, ulong volume=1, double sl=0, double tp=0)
    {
        if(price == NULL) price = bestbid + pricestep;
        CLimitOrder order = CLimitOrder(symbol, B, price, volume, sl, tp);
        AddOrder(order);
    };

    void SLim(double price=NULL, ulong volume=1, double sl=0, double tp=0)
    {
        if(price == NULL) price = bestask - pricestep;
        CLimitOrder order = CLimitOrder(symbol, S, price, volume, sl, tp);
        AddOrder(order);
    };
    /*
    CPosition Netto(string _symbol)
    {
        
    };
    /**/
protected:
    void AddOrder(CLimitOrder order)
    {
        if(order.accepted)
        {
            int index = ArrayResize(orders, ArraySize(orders)+1)-1;
            orders[index] = order;
        }
        else
            Print("Ордер не принят (шаг цены не учтён)");
    }; // Given price value doesn`t match symbol tick size
};