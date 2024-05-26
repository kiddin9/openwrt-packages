
(function () {
    const numberCol = 3;
    const wrt = {
        // variables for auto-update, interval is in seconds
        scheduleTimeout: undefined,
        interval: 5,
        // option on whether to show per host sub-totals
        perHostTotals: false,
        paused: false,
        headers: [],
        // variables for sorting
        sortData: {
            column: numberCol,
            elId: 'thDlb',
            dir: 'desc',
        },
        filter: '',
        ifaceFilter: '',
        cache: {},
    };

    let oldDate, oldValues, oldValuesSeconds;
    const basePath = "/cgi-bin/luci/admin/status/rtbwmon"
    //----------------------
    // HELPER FUNCTIONS
    //----------------------

    /**
     * Human readable text for size
     * @param size
     * @returns {string}
     */
    const getSize = function(size, suffix) {
        let prefix = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z'];
        let precision, base = 1000, pos = 0;
        while (size > base) {
            size /= base;
            pos++;
        }
        if (pos > 2) precision = 1000; else precision = 1;
        return (Math.round(size * precision) / precision) + ' ' + prefix[pos] + suffix;
    };

    /**
     * Human readable text for date
     * @param date
     * @returns {string}
     */
    const dateToString = function(date) {
        return date.toString().substring(0, 24);
    };

    /**
     * Gets the string representation of the date received from BE
     * @param value
     * @returns {*}
     */
    const getDateString = function(value) {
        let tmp = value.split('_'),
            str = tmp[0].split('-').reverse().join('-') + 'T' + tmp[1];
        return dateToString(new Date(str));
    };

    /**
     * Create a `tr` element with content
     * @param content
     * @returns {string}
     */
    const createTR = function(content) {
        let res = document.createElement('tr');
        res.classList.add("tr");
        res.innerHTML="";
        res.append(...content);
        return res;
    };

    /**
     * Create a `td` element with content and options
     * @param content
     * @param opts
     * @returns {string}
     */
    const createTD = function(content, opts) {
        opts = opts || {};
        let res = document.createElement('td');
        if (opts.right) {
            res.align="right";
        }
        if (opts.dataTitle) {
            res.setAttribute("data-title", opts.dataTitle);
        }
        res.classList.add("td");
        if (opts.title) {
            res.title=opts.title;
            res.classList.add("more_info");
        }
        res.innerHTML = content;
        return res;
    };

    const createTH = function(content, opts) {
        opts = opts || {};
        let res = document.createElement('th');
        if (opts.right) {
            res.align = "right";
        }
        if (opts.id) {
            res.id = opts.id;
        }
        res.classList.add("th");
        res.innerHTML = content;
        return res;
    };

    /**
     * Returns true if obj is instance of Array
     * @param obj
     * @returns {boolean}
     */
    const isArray = function(obj) {
        return obj instanceof Array;
    };

    //----------------------
    // END HELPER FUNCTIONS
    //----------------------

    // UI
    // TABLE
    const rowToTr = function(row) {
        let iptitle = undefined;
        if (wrt.perHostTotals && row[numberCol+5].length>1) {
            iptitle = row[numberCol+5].join('\n');
        }
        // create displayData
        let displayData = [
            createTD(row[0] + '<br>' + row[7], {title: iptitle, dataTitle: wrt.headers[0].title}),
            createTD(row[1], {dataTitle: wrt.headers[1].title}),
            createTD(getSize(row[numberCol], 'Bps'), {right: true, dataTitle: wrt.headers[2].title}),
            createTD(getSize(row[numberCol+1], 'pps'), {right: true, dataTitle: wrt.headers[3].title}),
            createTD(getSize(row[numberCol+2], 'Bps'), {right: true, dataTitle: wrt.headers[4].title}),
            createTD(getSize(row[numberCol+3], 'pps'), {right: true, dataTitle: wrt.headers[5].title}),
        ];

        // display row data
        return createTR(displayData);
    };

    const filterData = function(data) {
        if (wrt.filter == '') {
            return data;
        }
        let value = wrt.filter;
        return data.filter(row=>
            (row[numberCol+4] && row[numberCol+4].toLowerCase().indexOf(value.toLowerCase()) > -1) || (row[0].indexOf(value) > -1) || (row[1].toLowerCase().indexOf(value.toLowerCase()) > -1) ||
            (wrt.perHostTotals && row[numberCol+5].length>1 && row[numberCol+5].some(ip=>ip.indexOf(value) > -1))
        )
    };

    const filterIface = function(data) {
        if (wrt.ifaceFilter == '') {
            return data;
        }
        let value = wrt.ifaceFilter;
        return data.filter(row=>value==row[2]);
    };

    /**
     * Calculates per host sub-totals and adds them in the data input
     * @param data The data input
     */
    const aggregateHostTotals = function(data) {
        if (!wrt.perHostTotals) return data;

        let m = data.reduce((m, row)=>{
            let mac = row[1];
            let ary = m[mac];
            if (ary) {
                ary.push(row);
            } else {
                m[mac] = [row];
            }
            return m;
        }, {});
        let merged = [];
        for (let mac in m) {
            if (m.hasOwnProperty(mac)) {
                let rows = m[mac];
                rows.sort(sortingFunction);
                let mrow = rows[0].slice(); // clone
                mrow.push([mrow[0]]); // ip s
                rows.slice(1).reduce((m, row)=>{
                    if (!m[numberCol+4] && row[numberCol+4]) {
                        m[numberCol+4] = row[numberCol+4]; // hostname
                    }
                    m[m.length-1].push(row[0]);
                    for (let i=0; i<4; ++i) {
                        m[numberCol+i] += row[numberCol+i];
                    }
                    return m;
                }, mrow);
                merged.push(mrow);
            }
        }
        return merged;
    };

    /**
     * Sorting function used to sort the `data`. Uses the global sort settings
     * @param x first item to compare
     * @param y second item to compare
     * @returns {number} 1 for desc, -1 for asc, 0 for equal
     */
    const sortingFunction = function(x, y) {
        // get data from global variable
        let sortColumn = wrt.sortData.column, sortDirection = wrt.sortData.dir;
        let a = x[sortColumn];
        let b = y[sortColumn];
        if (a === b) {
            return 0;
        } else if (sortDirection === 'desc') {
            return a < b ? 1 : -1;
        } else {
            return a > b ? 1 : -1;
        }
    };

    /**
     * Renders the table body
     * @param data
     * @param totals
     */
    const renderTableData = function(data) {
        if (!isArray(data)) data=[];
        // sort data
        data = filterData(aggregateHostTotals(filterIface(data)))
        data.sort(sortingFunction);

        // display data
        let table = document.getElementById('clients');
        table.innerHTML="";
        table.append(...data.map(rowToTr));
    };

    // HEADER
    const updateHeader = function() {
        // set sorting arrows
        let th = document.getElementById('theader').firstElementChild;
        while(th) {
            th.firstElementChild.innerHTML = "&#x3000;";
            th = th.nextElementSibling;
        }
        let el = document.getElementById(wrt.sortData.elId);
        if (el) {
            el.firstElementChild.innerHTML = (wrt.sortData.dir === 'desc' ? '&#x25BC;' : '&#x25B2;');
        }
    };

    /**
     * Sets the relevant global sort variables and re-renders the table to apply the new sorting
     * @param elId
     * @param column
     */
    const setSortColumn = function(elId, column) {
        if (column === wrt.sortData.column) {
            // same column clicked, switch direction
            wrt.sortData.dir = wrt.sortData.dir === 'desc' ? 'asc' : 'desc';
        } else {
            // change sort column
            wrt.sortData.column = column;
            // reset sort direction
            wrt.sortData.dir = 'desc';
        }
        wrt.sortData.elId = elId;
        updateHeader();

        // render table data from cache
        renderTableData(wrt.cache.data);
    };

    /**
     * Registers the table events handlers for sorting when clicking the column headers
     */
    const registerTableEventHandlers = function() {
        // note these ordinals are into the data array, not the table output
        document.getElementById('thIp').addEventListener('click', function () {
            setSortColumn(this.id, 0); // ip
        });
        document.getElementById('thMac').addEventListener('click', function () {
            setSortColumn(this.id, 1); // mac
        });
        document.getElementById('thDlb').addEventListener('click', function () {
            setSortColumn(this.id, numberCol); // dl speed
        });
        document.getElementById('thDlp').addEventListener('click', function () {
            setSortColumn(this.id, numberCol+1); // dl pps
        });
        document.getElementById('thUpb').addEventListener('click', function () {
            setSortColumn(this.id, numberCol+2); // ul speed
        });
        document.getElementById('thUpp').addEventListener('click', function () {
            setSortColumn(this.id, numberCol+3); // ul pps
        });
    };

    const initHeader = function() {
        // set sorting arrows
        let theader = document.getElementById('theader');
        theader.innerHTML="";
        theader.append(...wrt.headers.map(h=>createTH(h.title, h)).map(th=>{
            th.appendChild(document.createElement("span"));
            return th;
        }));
    };

    // TOOLBAR
    /**
     * Registers DOM event listeners for user interaction
     */
    const addEventListeners = function() {
        document.getElementById('perHostTotals').addEventListener('change', function () {
            wrt.perHostTotals = this.checked;
            renderTableData(wrt.cache.data);
        });
        document.getElementById('pause_checkbox').addEventListener('change', function () {
            wrt.paused = this.checked;
        });
        document.getElementById('iface_select').addEventListener('change', function () {
            wrt.ifaceFilter = this.value;
            renderTableData(wrt.cache.data);
        });
        const submitFilter = function(value) {
            if (wrt.filter != value) {
                wrt.filter = value;
                renderTableData(wrt.cache.data);
            }
        };
        let filterInput = document.getElementById('filter_input');
        filterInput.addEventListener('keypress', function(event){
            if (event.key === 'Enter')
                submitFilter(this.value);
        });
        filterInput.addEventListener('blur', function(){
            submitFilter(this.value);
        });
    };

    // model
    /**
     * Handle the error that happened during the call to the BE
     */
    const handleError = function() {
        // TODO handle errors
        // let message = 'Something went wrong...';
    };

    /**
     * Handle the new `values` that were received from the BE
     * @param values
     * @returns {string}
     */
    const handleValues = function(values) {
        if (!isArray(values)) return;

        // find data and totals
        let data = parseValues(values);

        // store them in cache for quicker re-rendering
        wrt.cache.data = data;

        renderTableData(data);
    };

    /**
     * Parses the values and returns a data array, where each element in the data array is an array with two elements,
     * and a totals array, that holds aggregated values for each column.
     * The first element of each row in the data array, is the HTML output of the row as a `tr` element
     * and the second is the actual data:
     *  [ result, data ]
     * @param values The `values` array
     * @returns {Array}
     */
    const parseValues = function(values) {
        return values.map(parseValueRow).filter(a=>a!=null);
    };

    /**
     * Parse each row in the `values` array and return an array with two elements.
     * The first element is the HTML output of the row as a `tr` element and the second is the actual data
     *    [ result, data ]
     * @param data A row from the `values` array
     * @returns {[ string, [] ]}
     */
    const parseValueRow = function(data) {
        // check if data is array
        if (!isArray(data)) return null;

        // find download and upload speeds
        let dlSpeed = 0, upSpeed = 0;
        let dlPs = 0, upPs = 0;
        let seconds = oldValuesSeconds;
        if (typeof(seconds) !== 'undefined') {
            // find old data
            let oldData;
            for (let i = 0; i < oldValues.length; i++) {
                let cur = oldValues[i];
                // compare mac addresses and ip addresses
                if (oldValues[i][0] === data[0] && oldValues[i][1] === data[1]) {
                    oldData = cur;
                    break;
                }
            }
            if (typeof(oldData) === 'undefined') {
                // new ip
                oldData = [0,0,0,0,0,0,0,0,0,0,0,0,0];
            }
            upPs = Math.max(0, data[numberCol] - oldData[numberCol]) / seconds;
            upSpeed = Math.max(0, data[numberCol+1] - oldData[numberCol+1]) / seconds;
            dlPs = Math.max(0, data[numberCol+2] - oldData[numberCol+2]) / seconds;
            dlSpeed = Math.max(0, data[numberCol+3] - oldData[numberCol+3]) / seconds;
        }

        // create rowData [ip, mac, iface, dlSpeed, dlPs, upSpeed, upPs, hostname]
        let rowData = [data[0], data[1], data[2], dlSpeed, dlPs, upSpeed, upPs, data[numberCol+4]];

        return rowData;
    };

    const httpGet = function(url, cb, onerror) {
        let ajax = new XMLHttpRequest();
        ajax.onreadystatechange = function () {
            // noinspection EqualityComparisonWithCoercionJS
            if (this.readyState === XMLHttpRequest.DONE) {
                cb(this.status, this.responseText);
            }
        };
        ajax.open('GET', url, true);
        try {
            ajax.send();
        } catch (err) {
            onerror && onerror(err)
        }
    };

    /**
     * Fetches and handles the updated `values` from the BE
     */
    const receiveData = function() {
        if (wrt.paused) {
            reschedule();
            return
        }
        httpGet(basePath + '/data?t='+parseInt(new Date().getTime()/1000), function (status, responseText) {
            if (status == 200) {
                if (!wrt.paused) {
                    let v = responseText.trimEnd().split('\n')
                            .filter(line=>line).map(line=>{
                        let a = line.split(',');
                        for (let i=0;i<4;++i) {
                            a[numberCol+i] = parseInt(a[numberCol+i])
                        }
                        return a;
                    });
                    let now = new Date().getTime();
                    oldValuesSeconds = undefined;
                    if (typeof(oldValues) !== 'undefined') {
                        let seconds = (now - oldDate) / 1000;
                        if (seconds < 600) {
                            oldValuesSeconds = seconds;
                        }
                    }
                    handleValues(v);
                    // set old values
                    oldValues = v;
                    // set old date
                    oldDate = now;
                }
                reschedule();
            }
        });
    };

    //----------------------
    // AUTO-UPDATE
    //----------------------

    /**
     * Start auto-update schedule
     */
    const reschedule = function() {
        let seconds = wrt.interval || 60;
        wrt.scheduleTimeout = window.setTimeout(receiveData, seconds * 1000);
    };

    //----------------------
    // END AUTO-UPDATE
    //----------------------

    window.rtbwmon_init = function(headers){
        wrt.headers = headers;
        initHeader();
        updateHeader();
        // register events
        addEventListeners();
        // register table events
        registerTableEventHandlers();
        // Main entry point
        httpGet(basePath + '/ifaces?t='+parseInt(new Date().getTime()/1000), function (status, responseText) {
            receiveData();
            let iface_select = document.getElementById('iface_select');
            let selected = iface_select.value;
            let ifaces = responseText.trimEnd().split('\n').filter(line=>line).map(iface=>{
                let option = document.createElement('option');
                option.value = iface;
                option.innerHTML = iface;
                if (selected == iface) {
                    option.selected = true;
                }
                return option;
            });
            let first = iface_select.firstElementChild;
            iface_select.innerHTML="";
            iface_select.append(first, ...ifaces);
        }, function(err) {
            alert(err);
        });
    };

})();
