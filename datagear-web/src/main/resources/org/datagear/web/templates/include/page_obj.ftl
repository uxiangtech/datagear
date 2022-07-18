<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--页面JS对象块 -->
<script type="text/javascript">
var ${pid} =
{
	//父页面对象ID
	parentPid: "${parentPid}",
	
	//当前页面ID
	pid: "${pid}",
	
	contextPath: "${contextPath}",
	
	i18n:
	{
		confirm: "<@spring.message code='confirm' />",
		cancel : "<@spring.message code='cancel' />",
		operationConfirm : "<@spring.message code='operationConfirm' />"
	},
	
	//获取父页面JS对象
	parent: function()
	{
		var parentPage = (this.parentPid ? window[this.parentPid] : null);
		//父页面DOM元素可能会在回调过程中被删除，这里加一层元素判断
		return (!parentPage || parentPage.element().length == 0 ? null : parentPage);
	},
	
	//获取页面内的元素
	element: function(selector, parent)
	{
		return (selector == null ? $("#"+this.pid) : (parent ? $(selector, parent) : $(selector, $("#"+this.pid))));
	},
	
	//获取页面内指定id的元素
	elementOfId: function(id, parent)
	{
		return this.element("#"+id, parent);
	},
	
	//获取页面内指定name的元素
	elementOfName: function(name, parent)
	{
		return this.element("[name='"+name+"']", parent);
	},
	
	//打开URL
	open: function(url, options)
	{
		url = this.concatContextPath(url);
		url = $.addParam(url, "parentPid", this.pid);
		$.open(url, (options || {}));
	},
	
	//打开表格对话框
	openTableDialog: function(url, options)
	{
		options = $.extend({ width: "80vw" }, options);
		this.open(url, options);
	},
	
	//关闭此页面
	close: function()
	{
		$.closeDialog(this.element());
	},
	
	//页面是否在对话框内
	isInDialog: function()
	{
		return $.isInDialog(this.element());
	},
	
	//页面所在的对话框是否钉住
	isDialogPinned: function()
	{
		return false;
	},
	
	/**
	 * 获取页面参数对象。
	 * @param name 可选，页面参数对象属性名
	 */
	pageParam: function(name)
	{
		var ppo = $.pageParam(this.element());
		return (name == null ? ppo : (ppo ? ppo[name] : null));
	},
	
	/**
	 * 调用页面参数对象指定函数。
	 * @param functionName 必选
	 * @param arg,... 可选，函数参数
	 */
	pageParamCall: function(functionName, arg)
	{
		var argArray = (arg == undefined ? undefined : $.makeArray(arguments).slice(1));
		return $.pageParamCall(this.element(), functionName, argArray);
	},
	
	//打开确认对话框
	confirm: function(options)
	{
		var po = this;
		options = $.extend(
		{
			acceptLabel : po.i18n.confirm,
			rejectLabel : po.i18n.cancel,
			header : po.i18n.operationConfirm
		},
		options);
		
		$.confirm(options);
	},
	
	//连接应用根路径
	concatContextPath : function(path)
	{
		return (path.charAt(0) == "/" ? this.contextPath + path : path);
	},
	
	attr: function(name, value)
	{
		var attrs = (this._attrs || (this._attrs = {}));
		
		if(value === undefined)
			return attrs[name];
		else
			attrs[name] = value;
	},
	
	//获取/填充并返回vue页面模型，在vue页面中可以"pm.*"访问模型中的属性
	vuePageModel: function(obj)
	{
		return this.vueReactive("pm", obj);
	},
	
	//获取/填充并返回vue的setup响应式对象（自动reactive），对象格式必须为：{...}
	vueReactive: function(name, obj)
	{
		if(obj === undefined)
			return this._vueSetup[name];
		else
		{
			var rtvObj = (this._vueSetup[name] || (this._vueSetup[name] = Vue.reactive({})));
			
			for(var p in obj)
				rtvObj[p] = obj[p];
			
			return rtvObj;
		}
	},
	
	//设置vue的setup函数
	vueMethod: function(name, method)
	{
		var methodsObj = {};
		
		// ({ a: Function, b: Function)
		if(arguments.length == 1)
			methodsObj = name;
		// (name, Function)
		else if(arguments.length == 2)
			methodsObj[name] = method;
		
		for(var p in methodsObj)
			this._vueSetup[p] = methodsObj[p];
	},
	
	//获取/设置并返回vue的setup函数、响应式对象（自动reactive）
	vueSetup: function(name, value)
	{
		if(value === undefined)
			return this._vueSetup[name];
		else
		{
			if(typeof(value) == "function")
				this._vueSetup[name] = value;
			else
				this._vueSetup[name] = Vue.reactive(value);
			
			return this._vueSetup[name];
		}
	},
	
	//获取（自动unref）/设置（自动ref）vue的setup引用值
	vueRef: function(name, value)
	{
		var obj = this._vueSetup[name];
		
		if(value === undefined)
			return Vue.unref(obj);
		else
		{
			if(obj == null)	
				this._vueSetup[name] = Vue.ref(value);
			else
				obj.value = value;
		}
	},
	
	//设置vue的计算属性
	vueComputed: function(name, handler)
	{
		var computedObj = {};
		
		// ({ a: Function, b: Function)
		if(arguments.length == 1)
			computedObj = name;
		// (name, Function)
		else if(arguments.length == 2)
			computedObj[name] = handler;
		
		for(var p in computedObj)
			this._vueComputed[p] = computedObj[p];
	},
	
	//获取/设置vue组件
	vueComponent: function(name, value)
	{
		if(value === undefined)
			return this._vueComponents[name];
		else
			this._vueComponents[name] = value;
	},
	
	//设置vue监听
	vueWatch: function(target, callback)
	{
		this._vueWatch.push({ target: target, callback: callback });
	},
	
	//设置vue挂在后回调函数
	vueMounted: function(callback)
	{
		this._vueMounted.push(callback);
	},

	//获取reacitve的原始对象
	vueRaw: function(reactiveObj)
	{
		if($.isArray(reactiveObj))
		{
			var re = [];
			reactiveObj.forEach(function(item)
			{
				re.push(Vue.toRaw(item));
			});
			
			return re;
		}
		else
			return Vue.toRaw(reactiveObj);
	},
	
	//vue的setup对象
	_vueSetup: {},
	//vue的watch对象
	_vueWatch: [],
	//vue的watch对象
	_vueComputed: {},
	//vue的mounted回调函数
	_vueMounted: [],
	//vue组件
	_vueComponents:
	{
		"p-tabmenu": primevue.tabmenu,
		"p-contextmenu": primevue.contextmenu,
		"p-button": primevue.button,
		"p-datatable": primevue.datatable,
		"p-column": primevue.column,
		"p-inputtext": primevue.inputtext,
		"p-checkbox": primevue.checkbox,
		"p-textarea": primevue.textarea,
		"p-card": primevue.card,
		"p-dialog": primevue.dialog,
		"p-password": primevue.password,
		"p-divider": primevue.divider,
		"p-selectbutton": primevue.selectbutton,
		"p-dropdown": primevue.dropdown,
		"p-togglebutton": primevue.togglebutton,
		"p-splitbutton": primevue.splitbutton,
		"p-tree": primevue.tree,
		"p-tabview": primevue.tabview,
		"p-tabpanel": primevue.tabpanel,
		"p-menu": primevue.menu,
		"p-chip": primevue.chip
	},
	
	//vue挂载
	vueMount: function(app)
	{
		const setupObj = this._vueSetup;
		const watchObj = this._vueWatch;
		const computedObj = this._vueComputed;
		const mountedObj = this._vueMounted;
		const componentsObj = this._vueComponents;
		
		app = $.extend((app || {}),
		{
			setup()
			{
				watchObj.forEach(function(wt)
				{
					Vue.watch(wt.target, wt.callback);
				});
				
				for(var cpn in computedObj)
				{
					setupObj[cpn] = Vue.computed(computedObj[cpn]);
				}
				
				Vue.onMounted(function()
				{
					mountedObj.forEach(function(callback)
					{
						callback();
					});
					
					$.initGlobalTip();
					$.initGlobalConfirm();
				});
				
				return setupObj;
			},
			components: componentsObj
		});
		
		this._vueApp = Vue.createApp(app).use(primevue.config.default).mount("#"+this.pid);
		return this._vueApp;
	},
	
	//获取挂载后的vue实例
	vueApp: function()
	{
		return this._vueApp;
	}
};
</script>
