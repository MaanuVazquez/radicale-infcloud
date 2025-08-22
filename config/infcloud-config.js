// InfCloud Configuration
var globalInterfaceLanguage = 'en_US';
var globalInterfaceCustomLanguages = [];

// Server settings - configure for Radicale (single process)
var globalAccountSettings = [
    {
        href: '../',
        userAuth: {
            userName: '',
            userPassword: ''
        },
        timeOut: 90000,
        lockTimeOut: 10000,
        checkContentType: true,
        settingsAccount: true,
        delegation: false,
        additionalResources: [],
        hrefLabel: null,
        forceReadOnly: null,
        ignoreAlarms: false,
        backgroundCalendars: []
    }
];

// Login page settings
var globalNetworkCheckSettings = {
    href: '../',
    timeOut: 30000,
    repeat: false,
    allowSelfSigned: false,
    checkHeader: 'DAV'
};

var globalLoginSettings = {
    checkOutdatedBrowser: true,
    defaultLoginUsername: '',
    defaultLoginPassword: '',
    hideLoginUsername: false,
    hideLoginPassword: false,
    loginMessage: 'Please enter your username and password:'
};

// Interface settings
var globalSettings = {
    version: '0.13.1',
    
    // Calendar settings
    enableCalendar: true,
    calendarStart: 1, // Monday
    datepickerFormat: 'dd/mm/yy',
    timepickerFormat: 'HH:mm',
    calendarDisplayHiddenEvents: false,
    
    // AddressBook settings  
    enableAddressbook: true,
    contactStoreFN: ['prefix', 'givenname', 'middlename', 'familyname', 'suffix'],
    
    // Interface
    enableSettings: true,
    enableKbNavigation: true,
    reloadInterval: 120000,
    enableRefresh: true,
    
    // Themes
    activeView: 'multiWeek',
    todoListFilterSelected: 'filter_all',
    calendarSelected: '',
    calendarColorSelected: '#ff9999',
    calendarColorSelected2: '#ff0000',
    
    // Advanced
    titleFormat: null,
    backgroundSync: true,
    enableParsingWorker: true
};

// Advanced features
var globalResourceSettings = {
    addressbookDisplayUrl: false,
    calendarDisplayUrl: false,
    useJqueryAuth: false,
    syncToken: true,
    loadBalancing: false,
    parallelAjax: false,
    forceBasicAuth: false,
    ignoreCompany: false
};

// Mobile/responsive settings
var globalMobileSettings = {
    enableMobileInterface: true,
    mobileCalendarStartOfWeek: 1,
    mobileTodoStartOfWeek: 1
};

// Development and debug
var globalDebugSettings = {
    enableDevelBuilds: false,
    logLevel: 1 // 0=off, 1=basic, 2=verbose
};

// Localization
var globalInterfaceSettings = {
    titleDatepicker: 'yyyy-mm-dd',
    dateFormatShort: 'dd.mm.yyyy',
    dateFormatLong: 'dd.mm.yyyy'
};
