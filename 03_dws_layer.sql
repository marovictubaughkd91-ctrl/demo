<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单数据分析看板</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif;
            background: linear-gradient(135deg, #0c1929 0%, #1a2a4a 50%, #0d2137 100%);
            color: #e0e8f0;
            min-height: 100vh;
        }
        .header {
            text-align: center;
            padding: 24px 0 12px;
            background: rgba(10, 25, 50, 0.8);
            border-bottom: 2px solid #1e90ff;
        }
        .header h1 {
            font-size: 28px;
            background: linear-gradient(90deg, #00d4ff, #1e90ff, #00d4ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 6px;
        }
        .header p { color: #7eb8da; margin-top: 4px; font-size: 14px; }
        .dashboard {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            padding: 20px;
            max-width: 1600px;
            margin: 0 auto;
        }
        .card {
            background: rgba(15, 35, 65, 0.85);
            border: 1px solid rgba(30, 144, 255, 0.3);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 30px rgba(30, 144, 255, 0.2);
        }
        .card-title {
            font-size: 18px;
            font-weight: bold;
            color: #1e90ff;
            margin-bottom: 16px;
            padding-left: 12px;
            border-left: 4px solid #1e90ff;
        }
        .chart-container { width: 100%; height: 380px; }
        .table-container {
            max-height: 400px;
            overflow-y: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        thead th {
            background: rgba(30, 144, 255, 0.2);
            color: #1e90ff;
            padding: 10px 8px;
            text-align: center;
            position: sticky;
            top: 0;
            z-index: 1;
        }
        tbody td {
            padding: 8px;
            text-align: center;
            border-bottom: 1px solid rgba(30, 144, 255, 0.1);
        }
        tbody tr:hover { background: rgba(30, 144, 255, 0.1); }
        .tag {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 12px;
            font-size: 12px;
        }
        .tag-completed { background: rgba(46, 204, 113, 0.2); color: #2ecc71; }
        .tag-cancelled { background: rgba(231, 76, 60, 0.2); color: #e74c3c; }
        .tag-paid      { background: rgba(52, 152, 219, 0.2); color: #3498db; }
        .tag-refunded  { background: rgba(243, 156, 18, 0.2); color: #f39c12; }
        .full-width { grid-column: 1 / -1; }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.1); }
        ::-webkit-scrollbar-thumb { background: rgba(30,144,255,0.4); border-radius: 3px; }

        @media (max-width: 900px) {
            .dashboard { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="header">
    <h1>订单数据分析看板</h1>
    <p>基于Hive分层架构(ODS-DWD-DWS-ADS)的数据仓库分析系统</p>
</div>

<div class="dashboard">
    <!-- 维度1：地区销售分析 -->
    <div class="card">
        <div class="card-title">维度1：地区销售分析</div>
        <div id="chart_region" class="chart-container"></div>
    </div>

    <!-- 维度2：品类销售分析 -->
    <div class="card">
        <div class="card-title">维度2：品类销售分析</div>
        <div id="chart_category" class="chart-container"></div>
    </div>

    <!-- 维度3：支付方式分析 -->
    <div class="card">
        <div class="card-title">维度3：支付方式分析</div>
        <div id="chart_payment" class="chart-container"></div>
    </div>

    <!-- 维度4：订单状态分析 -->
    <div class="card">
        <div class="card-title">维度4：订单状态分析</div>
        <div id="chart_status" class="chart-container"></div>
    </div>

    <!-- 维度5：月度销售趋势（全宽） -->
    <div class="card full-width">
        <div class="card-title">维度5：月度销售趋势</div>
        <div id="chart_monthly" class="chart-container"></div>
    </div>

    <!-- 数据明细表 -->
    <div class="card full-width">
        <div class="card-title">数据明细</div>
        <div style="display:flex; gap:20px; flex-wrap:wrap;">
            <div style="flex:1; min-width:400px;">
                <h4 style="color:#1e90ff; margin-bottom:8px;">地区销售明细</h4>
                <div class="table-container" id="table_region"></div>
            </div>
            <div style="flex:1; min-width:400px;">
                <h4 style="color:#1e90ff; margin-bottom:8px;">品类销售明细</h4>
                <div class="table-container" id="table_category"></div>
            </div>
            <div style="flex:1; min-width:400px;">
                <h4 style="color:#1e90ff; margin-bottom:8px;">支付方式明细</h4>
                <div class="table-container" id="table_payment"></div>
            </div>
            <div style="flex:1; min-width:400px;">
                <h4 style="color:#1e90ff; margin-bottom:8px;">订单状态明细</h4>
                <div class="table-container" id="table_status"></div>
            </div>
        </div>
    </div>
</div>

<script>
const COLORS = ['#1e90ff','#00d4ff','#2ecc71','#f39c12','#e74c3c','#9b59b6','#1abc9c','#e67e22'];

// ========== 维度1：地区销售柱状图 ==========
fetch('/api/region_sales').then(r=>r.json()).then(data => {
    const chart = echarts.init(document.getElementById('chart_region'));
    chart.setOption({
        tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
        legend: { data: ['销售总额', '订单总数'], textStyle: { color: '#ccc' } },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: data.map(d=>d.region), axisLabel: { color: '#ccc' } },
        yAxis: [
            { type: 'value', name: '金额', axisLabel: { color: '#ccc' }, splitLine: { lineStyle: { color: 'rgba(30,144,255,0.1)' } } },
            { type: 'value', name: '订单数', axisLabel: { color: '#ccc' }, splitLine: { show: false } }
        ],
        series: [
            { name: '销售总额', type: 'bar', data: data.map(d=>d.total_amount), itemStyle: { color: new echarts.graphic.LinearGradient(0,0,0,1,[{offset:0,color:'#1e90ff'},{offset:1,color:'#004080'}]) } },
            { name: '订单总数', type: 'bar', yAxisIndex: 1, data: data.map(d=>d.total_orders), itemStyle: { color: new echarts.graphic.LinearGradient(0,0,0,1,[{offset:0,color:'#2ecc71'},{offset:1,color:'#0d5c2e'}]) } }
        ]
    });
    window.addEventListener('resize', () => chart.resize());
    document.getElementById('table_region').innerHTML = '<table><thead><tr><th>排名</th><th>地区</th><th>订单数</th><th>销售额</th><th>客单价</th><th>已完成</th><th>已取消</th><th>已退款</th></tr></thead><tbody>' + data.map(d=>`<tr><td>${d.amount_rank}</td><td>${d.region}</td><td>${d.total_orders}</td><td>${d.total_amount}</td><td>${d.avg_order_amount}</td><td>${d.completed_orders}</td><td>${d.cancelled_orders}</td><td>${d.refunded_orders}</td></tr>`).join('') + '</tbody></table>';
});

// ========== 维度2：品类销售饼图 ==========
fetch('/api/category_sales').then(r=>r.json()).then(data => {
    const chart = echarts.init(document.getElementById('chart_category'));
    chart.setOption({
        tooltip: { trigger: 'item' },
        legend: { orient: 'vertical', right: '5%', top: 'center', textStyle: { color: '#ccc' } },
        series: [{
            type: 'pie', radius: ['35%', '65%'], center: ['40%', '50%'],
            data: data.map((d,i) => ({ name: d.category, value: d.total_amount, itemStyle: { color: COLORS[i % COLORS.length] } })),
            label: { color: '#ccc', formatter: '{b}\n{d}%' },
            emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.5)' } }
        }]
    });
    window.addEventListener('resize', () => chart.resize());
    document.getElementById('table_category').innerHTML = '<table><thead><tr><th>排名</th><th>品类</th><th>订单数</th><th>销售额</th><th>占比(%)</th><th>客单价</th><th>均价</th></tr></thead><tbody>' + data.map(d=>`<tr><td>${d.amount_rank}</td><td>${d.category}</td><td>${d.total_orders}</td><td>${d.total_amount}</td><td>${d.amount_ratio}</td><td>${d.avg_order_amount}</td><td>${d.avg_price}</td></tr>`).join('') + '</tbody></table>';
});

// ========== 维度3：支付方式玫瑰图 ==========
fetch('/api/payment_analysis').then(r=>r.json()).then(data => {
    const chart = echarts.init(document.getElementById('chart_payment'));
    chart.setOption({
        tooltip: { trigger: 'item' },
        legend: { bottom: '5%', textStyle: { color: '#ccc' } },
        series: [{
            type: 'pie', radius: ['20%', '65%'], center: ['50%', '45%'], roseType: 'area',
            data: data.map((d,i) => ({ name: d.payment_method, value: d.total_amount, itemStyle: { color: COLORS[i % COLORS.length] } })),
            label: { color: '#ccc', formatter: '{b}\n完成率: {c}' }
        }]
    });
    window.addEventListener('resize', () => chart.resize());
    document.getElementById('table_payment').innerHTML = '<table><thead><tr><th>支付方式</th><th>订单数</th><th>销售额</th><th>完成率(%)</th><th>订单占比(%)</th><th>金额占比(%)</th></tr></thead><tbody>' + data.map(d=>`<tr><td>${d.payment_method}</td><td>${d.total_orders}</td><td>${d.total_amount}</td><td>${d.completed_rate}</td><td>${d.order_ratio}</td><td>${d.amount_ratio}</td></tr>`).join('') + '</tbody></table>';
});

// ========== 维度4：订单状态环形图 ==========
fetch('/api/order_status').then(r=>r.json()).then(data => {
    const chart = echarts.init(document.getElementById('chart_status'));
    const statusColors = { completed:'#2ecc71', paid:'#3498db', cancelled:'#e74c3c', refunded:'#f39c12' };
    chart.setOption({
        tooltip: { trigger: 'item' },
        legend: { bottom: '5%', textStyle: { color: '#ccc' } },
        series: [{
            type: 'pie', radius: ['40%', '65%'], center: ['50%', '45%'],
            data: data.map(d => ({ name: d.status, value: d.total_orders, itemStyle: { color: statusColors[d.status] || '#1e90ff' } })),
            label: { color: '#ccc', formatter: '{b}\n{d}%' }
        }]
    });
    window.addEventListener('resize', () => chart.resize());
    document.getElementById('table_status').innerHTML = '<table><thead><tr><th>状态</th><th>订单数</th><th>订单占比(%)</th><th>涉及金额</th><th>金额占比(%)</th><th>客单价</th></tr></thead><tbody>' + data.map(d=>`<tr><td><span class="tag tag-${d.status}">${d.status}</span></td><td>${d.total_orders}</td><td>${d.order_ratio}</td><td>${d.total_amount}</td><td>${d.amount_ratio}</td><td>${d.avg_order_amount}</td></tr>`).join('') + '</tbody></table>';
});

// ========== 维度5：月度销售趋势折线图 ==========
fetch('/api/monthly_trend').then(function(res) { return res.json(); }).then(function(data) {
    if (!data || data.length === 0) return;
    var el = document.getElementById('chart_monthly');
    if (!el) return;
    var chart = echarts.init(el);
    chart.setOption({
        tooltip: { trigger: 'axis' },
        legend: { data: ['销售额', '订单数'], textStyle: { color: '#ccc' } },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: data.map(function(d){return d.order_yearmonth;}), axisLabel: { color: '#ccc' } },
        yAxis: [
            { type: 'value', name: '金额', axisLabel: { color: '#ccc' }, splitLine: { lineStyle: { color: 'rgba(30,144,255,0.1)' } } },
            { type: 'value', name: '订单数', axisLabel: { color: '#ccc' }, splitLine: { show: false } }
        ],
        series: [
            { name: '销售额', type: 'line', smooth: true, data: data.map(function(d){return d.total_amount;}),
              lineStyle: { color: '#1e90ff', width: 3 },
              areaStyle: { color: new echarts.graphic.LinearGradient(0,0,0,1,[{offset:0,color:'rgba(30,144,255,0.3)'},{offset:1,color:'rgba(30,144,255,0)'}]) },
              itemStyle: { color: '#1e90ff' } },
            { name: '订单数', type: 'bar', yAxisIndex: 1, data: data.map(function(d){return d.total_orders;}),
              itemStyle: { color: 'rgba(46,204,113,0.6)' } }
        ]
    });
    window.addEventListener('resize', function(){ chart.resize(); });
});
</script>
</body>
</html>
