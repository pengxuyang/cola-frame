properties =
	contextPath: "/"
	serviceUrlPattern: /^\/?service\/[a-z]+/
	serviceUrlPrefix: "/"
	htmlSuffix: ""
	mainView: "/frame/main"
	loginPath: "/login"
	longPollingTimeout: 0
	longPollingInterval: 2000
	"service.messagePull": "/service/message/pull"
	"service.login": "/service/account/login"
	"service.logout": "/service/account/logout"
	"service.menus": "/service/menus"
	"service.user.detail": "/service/user/detail"

App = window.App =
	_tabs: {}
	open: (path, config)->
		viewTab = cola.widget("viewTab")
		if @_tabs[path]
			tab = viewTab.getTab(path)
			viewTab.setCurrentTab(tab)
		else
			if config.type != "subWindow"
				window.open(path)
				return
			tab = new cola.TabButton({
				afterClose: (self, arg)=> @.close(self.get("name"))
				content:
					$type: "iFrame"
					path: config.path
				icon: config.icon
				name: path
				closeable: config.closeable or true
				caption: config.label
			})
			viewTab = cola.widget("viewTab")
			@_tabs[path] = tab
			viewTab.addTab(tab)
			viewTab.setCurrentTab(tab)
	close: (path)->
		delete @_tabs[path]
	goLogin: ()->

	prop: (key, value)->
		if arguments.length == 1
			if typeof  key == "string"
				return properties[key]
			else if key
				for p in key
					if key.hasOwnProperty(p) then properties[p] = key[p]
		else
			properties[key] = value


cola.defaultAction("setting", (key)->
	return App.prop(key)
)

cola.defaultAction("numberString", (number)->
	return ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve",
	        "thirteen", "fourteen", "fifteen", "sixteen"][number - 1];
)
$(document).ajaxError((event, jqXHR)->
	if jqXHR.status == 401
		App.goLogin();
		return false;
	else
		message = jqXHR.responseJSON;
		if message then throw new cola.Exception(message)
	return
);
language = $.cookie("_language") || window.navigator.language;

if language
	document.write("<script src=\"resources/cola-ui/i18n/#{language}/cola.js\"></script>");
	document.write("<script src=\"resources/i18n/#{language}/common.js\"></script>");
$(NProgress.done)