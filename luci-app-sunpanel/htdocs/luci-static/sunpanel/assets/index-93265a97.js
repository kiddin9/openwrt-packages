import{t as Bt,f as ge,q as Ne,H as Pt,y as B,B as Pe,L as Ve,F as Ye,g as f,ac as Me,G as J,S as Vt,aE as Mt,bT as Nt,m as h,p as x,n as A,z as le,cJ as It,r as N,a6 as Ut,as as Dt,aM as Ft,ab as L,cK as jt,K as _,J as Qe,v as Ht,x as Ot,cL as At,a5 as lt,w as qe,R as We,b as Et,N as Wt,T as Kt,e as ze,c as $e,ad as et,aj as tt,cM as Lt,A as Z,aH as Ke,aw as W,cC as Le,ah as Xt,bJ as Yt,bl as qt,bv as Gt,bn as Jt,bo as Te,bc as Re,cN as Zt,aW as Q,aX as ee,b4 as u,a$ as C,b3 as d,b1 as y,b2 as n,bC as K,b5 as ie,aZ as Qt,b0 as Xe,by as en,bz as tn}from"./index-7e19b821.js";import{b as nt,N as nn,p as on,u as rt,d as Ge,V as an,e as sn,g as ln}from"./index-c238f14b.js";import{N as Be,b as ot}from"./index-2b595d91.js";import{j as rn,N as dn,k as cn,l as un}from"./index-bc9666b7.js";import{k as hn,l as ve}from"./index-b1d3d9b0.js";import{_ as fn}from"./_plugin-vue_export-helper-c27b6911.js";const dt=Bt("n-popconfirm"),ct={positiveText:String,negativeText:String,showIcon:{type:Boolean,default:!0},onPositiveClick:{type:Function,required:!0},onNegativeClick:{type:Function,required:!0}},at=Nt(ct),vn=ge({name:"NPopconfirmPanel",props:ct,setup(e){const{localeRef:c}=nt("Popconfirm"),{inlineThemeDisabled:s}=Ne(),{mergedClsPrefixRef:g,mergedThemeRef:p,props:m}=Pt(dt),$=B(()=>{const{common:{cubicBezierEaseInOut:k},self:{fontSize:z,iconSize:T,iconColor:r}}=p.value;return{"--n-bezier":k,"--n-font-size":z,"--n-icon-size":T,"--n-icon-color":r}}),w=s?Pe("popconfirm-panel",void 0,$,m):void 0;return Object.assign(Object.assign({},nt("Popconfirm")),{mergedClsPrefix:g,cssVars:s?void 0:$,localizedPositiveText:B(()=>e.positiveText||c.value.positiveText),localizedNegativeText:B(()=>e.negativeText||c.value.negativeText),positiveButtonProps:Ve(m,"positiveButtonProps"),negativeButtonProps:Ve(m,"negativeButtonProps"),handlePositiveClick(k){e.onPositiveClick(k)},handleNegativeClick(k){e.onNegativeClick(k)},themeClass:w==null?void 0:w.themeClass,onRender:w==null?void 0:w.onRender})},render(){var e;const{mergedClsPrefix:c,showIcon:s,$slots:g}=this,p=Ye(g.action,()=>this.negativeText===null&&this.positiveText===null?[]:[this.negativeText!==null&&f(Me,Object.assign({size:"small",onClick:this.handleNegativeClick},this.negativeButtonProps),{default:()=>this.localizedNegativeText}),this.positiveText!==null&&f(Me,Object.assign({size:"small",type:"primary",onClick:this.handlePositiveClick},this.positiveButtonProps),{default:()=>this.localizedPositiveText})]);return(e=this.onRender)===null||e===void 0||e.call(this),f("div",{class:[`${c}-popconfirm__panel`,this.themeClass],style:this.cssVars},J(g.default,m=>s||m?f("div",{class:`${c}-popconfirm__body`},s?f("div",{class:`${c}-popconfirm__icon`},Ye(g.icon,()=>[f(Vt,{clsPrefix:c},{default:()=>f(Mt,null)})])):null,m):null),p?f("div",{class:[`${c}-popconfirm__action`]},p):null)}}),pn=h("popconfirm",[x("body",`
 font-size: var(--n-font-size);
 display: flex;
 align-items: center;
 flex-wrap: nowrap;
 position: relative;
 `,[x("icon",`
 display: flex;
 font-size: var(--n-icon-size);
 color: var(--n-icon-color);
 transition: color .3s var(--n-bezier);
 margin: 0 8px 0 0;
 `)]),x("action",`
 display: flex;
 justify-content: flex-end;
 `,[A("&:not(:first-child)","margin-top: 8px"),h("button",[A("&:not(:last-child)","margin-right: 8px;")])])]),mn=Object.assign(Object.assign(Object.assign({},le.props),on),{positiveText:String,negativeText:String,showIcon:{type:Boolean,default:!0},trigger:{type:String,default:"click"},positiveButtonProps:Object,negativeButtonProps:Object,onPositiveClick:Function,onNegativeClick:Function}),gn=ge({name:"Popconfirm",props:mn,__popover__:!0,setup(e){const{mergedClsPrefixRef:c}=Ne(),s=le("Popconfirm","-popconfirm",pn,It,e,c),g=N(null);function p(w){var k;if(!(!((k=g.value)===null||k===void 0)&&k.getMergedShow()))return;const{onPositiveClick:z,"onUpdate:show":T}=e;Promise.resolve(z?z(w):!0).then(r=>{var a;r!==!1&&((a=g.value)===null||a===void 0||a.setShow(!1),T&&L(T,!1))})}function m(w){var k;if(!(!((k=g.value)===null||k===void 0)&&k.getMergedShow()))return;const{onNegativeClick:z,"onUpdate:show":T}=e;Promise.resolve(z?z(w):!0).then(r=>{var a;r!==!1&&((a=g.value)===null||a===void 0||a.setShow(!1),T&&L(T,!1))})}return Ut(dt,{mergedThemeRef:s,mergedClsPrefixRef:c,props:e}),{setShow(w){var k;(k=g.value)===null||k===void 0||k.setShow(w)},syncPosition(){var w;(w=g.value)===null||w===void 0||w.syncPosition()},mergedTheme:s,popoverInstRef:g,handlePositiveClick:p,handleNegativeClick:m}},render(){const{$slots:e,$props:c,mergedTheme:s}=this;return f(nn,Ft(c,at,{theme:s.peers.Popover,themeOverrides:s.peerOverrides.Popover,internalExtraClass:["popconfirm"],ref:"popoverInstRef"}),{trigger:e.activator||e.trigger,default:()=>{const g=Dt(c,at);return f(vn,Object.assign(Object.assign({},g),{onPositiveClick:this.handlePositiveClick,onNegativeClick:this.handleNegativeClick}),e)}})}});function st(e){return window.TouchEvent&&e instanceof window.TouchEvent}function it(){const e=new Map,c=s=>g=>{e.set(s,g)};return jt(()=>{e.clear()}),[e,c]}const bn=A([h("slider",`
 display: block;
 padding: calc((var(--n-handle-size) - var(--n-rail-height)) / 2) 0;
 position: relative;
 z-index: 0;
 width: 100%;
 cursor: pointer;
 user-select: none;
 -webkit-user-select: none;
 `,[_("reverse",[h("slider-handles",[h("slider-handle-wrapper",`
 transform: translate(50%, -50%);
 `)]),h("slider-dots",[h("slider-dot",`
 transform: translateX(50%, -50%);
 `)]),_("vertical",[h("slider-handles",[h("slider-handle-wrapper",`
 transform: translate(-50%, -50%);
 `)]),h("slider-marks",[h("slider-mark",`
 transform: translateY(calc(-50% + var(--n-dot-height) / 2));
 `)]),h("slider-dots",[h("slider-dot",`
 transform: translateX(-50%) translateY(0);
 `)])])]),_("vertical",`
 padding: 0 calc((var(--n-handle-size) - var(--n-rail-height)) / 2);
 width: var(--n-rail-width-vertical);
 height: 100%;
 `,[h("slider-handles",`
 top: calc(var(--n-handle-size) / 2);
 right: 0;
 bottom: calc(var(--n-handle-size) / 2);
 left: 0;
 `,[h("slider-handle-wrapper",`
 top: unset;
 left: 50%;
 transform: translate(-50%, 50%);
 `)]),h("slider-rail",`
 height: 100%;
 `,[x("fill",`
 top: unset;
 right: 0;
 bottom: unset;
 left: 0;
 `)]),_("with-mark",`
 width: var(--n-rail-width-vertical);
 margin: 0 32px 0 8px;
 `),h("slider-marks",`
 top: calc(var(--n-handle-size) / 2);
 right: unset;
 bottom: calc(var(--n-handle-size) / 2);
 left: 22px;
 font-size: var(--n-mark-font-size);
 `,[h("slider-mark",`
 transform: translateY(50%);
 white-space: nowrap;
 `)]),h("slider-dots",`
 top: calc(var(--n-handle-size) / 2);
 right: unset;
 bottom: calc(var(--n-handle-size) / 2);
 left: 50%;
 `,[h("slider-dot",`
 transform: translateX(-50%) translateY(50%);
 `)])]),_("disabled",`
 cursor: not-allowed;
 opacity: var(--n-opacity-disabled);
 `,[h("slider-handle",`
 cursor: not-allowed;
 `)]),_("with-mark",`
 width: 100%;
 margin: 8px 0 32px 0;
 `),A("&:hover",[h("slider-rail",{backgroundColor:"var(--n-rail-color-hover)"},[x("fill",{backgroundColor:"var(--n-fill-color-hover)"})]),h("slider-handle",{boxShadow:"var(--n-handle-box-shadow-hover)"})]),_("active",[h("slider-rail",{backgroundColor:"var(--n-rail-color-hover)"},[x("fill",{backgroundColor:"var(--n-fill-color-hover)"})]),h("slider-handle",{boxShadow:"var(--n-handle-box-shadow-hover)"})]),h("slider-marks",`
 position: absolute;
 top: 18px;
 left: calc(var(--n-handle-size) / 2);
 right: calc(var(--n-handle-size) / 2);
 `,[h("slider-mark",`
 position: absolute;
 transform: translateX(-50%);
 white-space: nowrap;
 `)]),h("slider-rail",`
 width: 100%;
 position: relative;
 height: var(--n-rail-height);
 background-color: var(--n-rail-color);
 transition: background-color .3s var(--n-bezier);
 border-radius: calc(var(--n-rail-height) / 2);
 `,[x("fill",`
 position: absolute;
 top: 0;
 bottom: 0;
 border-radius: calc(var(--n-rail-height) / 2);
 transition: background-color .3s var(--n-bezier);
 background-color: var(--n-fill-color);
 `)]),h("slider-handles",`
 position: absolute;
 top: 0;
 right: calc(var(--n-handle-size) / 2);
 bottom: 0;
 left: calc(var(--n-handle-size) / 2);
 `,[h("slider-handle-wrapper",`
 outline: none;
 position: absolute;
 top: 50%;
 transform: translate(-50%, -50%);
 cursor: pointer;
 display: flex;
 `,[h("slider-handle",`
 height: var(--n-handle-size);
 width: var(--n-handle-size);
 border-radius: 50%;
 overflow: hidden;
 transition: box-shadow .2s var(--n-bezier), background-color .3s var(--n-bezier);
 background-color: var(--n-handle-color);
 box-shadow: var(--n-handle-box-shadow);
 `,[A("&:hover",`
 box-shadow: var(--n-handle-box-shadow-hover);
 `)]),A("&:focus",[h("slider-handle",`
 box-shadow: var(--n-handle-box-shadow-focus);
 `,[A("&:hover",`
 box-shadow: var(--n-handle-box-shadow-active);
 `)])])])]),h("slider-dots",`
 position: absolute;
 top: 50%;
 left: calc(var(--n-handle-size) / 2);
 right: calc(var(--n-handle-size) / 2);
 `,[_("transition-disabled",[h("slider-dot","transition: none;")]),h("slider-dot",`
 transition:
 border-color .3s var(--n-bezier),
 box-shadow .3s var(--n-bezier),
 background-color .3s var(--n-bezier);
 position: absolute;
 transform: translate(-50%, -50%);
 height: var(--n-dot-height);
 width: var(--n-dot-width);
 border-radius: var(--n-dot-border-radius);
 overflow: hidden;
 box-sizing: border-box;
 border: var(--n-dot-border);
 background-color: var(--n-dot-color);
 `,[_("active","border: var(--n-dot-border-active);")])])]),h("slider-handle-indicator",`
 font-size: var(--n-font-size);
 padding: 6px 10px;
 border-radius: var(--n-indicator-border-radius);
 color: var(--n-indicator-text-color);
 background-color: var(--n-indicator-color);
 box-shadow: var(--n-indicator-box-shadow);
 `,[Qe()]),h("slider-handle-indicator",`
 font-size: var(--n-font-size);
 padding: 6px 10px;
 border-radius: var(--n-indicator-border-radius);
 color: var(--n-indicator-text-color);
 background-color: var(--n-indicator-color);
 box-shadow: var(--n-indicator-box-shadow);
 `,[_("top",`
 margin-bottom: 12px;
 `),_("right",`
 margin-left: 12px;
 `),_("bottom",`
 margin-top: 12px;
 `),_("left",`
 margin-right: 12px;
 `),Qe()]),Ht(h("slider",[h("slider-dot","background-color: var(--n-dot-color-modal);")])),Ot(h("slider",[h("slider-dot","background-color: var(--n-dot-color-popover);")]))]),xn=0,wn=Object.assign(Object.assign({},le.props),{to:Ge.propTo,defaultValue:{type:[Number,Array],default:0},marks:Object,disabled:{type:Boolean,default:void 0},formatTooltip:Function,keyboard:{type:Boolean,default:!0},min:{type:Number,default:0},max:{type:Number,default:100},step:{type:[Number,String],default:1},range:Boolean,value:[Number,Array],placement:String,showTooltip:{type:Boolean,default:void 0},tooltip:{type:Boolean,default:!0},vertical:Boolean,reverse:Boolean,"onUpdate:value":[Function,Array],onUpdateValue:[Function,Array],onDragstart:[Function],onDragend:[Function]}),pe=ge({name:"Slider",props:wn,setup(e){const{mergedClsPrefixRef:c,namespaceRef:s,inlineThemeDisabled:g}=Ne(e),p=le("Slider","-slider",bn,At,e,c),m=N(null),[$,w]=it(),[k,z]=it(),T=N(new Set),r=lt(e),{mergedDisabledRef:a}=r,l=B(()=>{const{step:t}=e;if(Number(t)<=0||t==="mark")return 0;const o=t.toString();let i=0;return o.includes(".")&&(i=o.length-o.indexOf(".")-1),i}),D=N(e.defaultValue),Ie=Ve(e,"value"),re=rt(Ie,D),I=B(()=>{const{value:t}=re;return(e.range?t:[t]).map(Y)}),be=B(()=>I.value.length>2),Ue=B(()=>e.placement===void 0?e.vertical?"right":"top":e.placement),xe=B(()=>{const{marks:t}=e;return t?Object.keys(t).map(parseFloat):null}),U=N(-1),de=N(-1),M=N(-1),b=N(!1),E=N(!1),X=B(()=>{const{vertical:t,reverse:o}=e;return t?o?"top":"bottom":o?"right":"left"}),te=B(()=>{if(be.value)return;const t=I.value,o=ne(e.range?Math.min(...t):e.min),i=ne(e.range?Math.max(...t):t[0]),{value:v}=X;return e.vertical?{[v]:`${o}%`,height:`${i-o}%`}:{[v]:`${o}%`,width:`${i-o}%`}}),ce=B(()=>{const t=[],{marks:o}=e;if(o){const i=I.value.slice();i.sort((P,V)=>P-V);const{value:v}=X,{value:S}=be,{range:R}=e,H=S?()=>!1:P=>R?P>=i[0]&&P<=i[i.length-1]:P<=i[0];for(const P of Object.keys(o)){const V=Number(P);t.push({active:H(V),label:o[P],style:{[v]:`${ne(V)}%`}})}}return t});function ue(t,o){const i=ne(t),{value:v}=X;return{[v]:`${i}%`,zIndex:o===U.value?1:0}}function we(t){return e.showTooltip||M.value===t||U.value===t&&b.value}function De(t){return b.value?!(U.value===t&&de.value===t):!0}function Fe(t){var o;~t&&(U.value=t,(o=$.get(t))===null||o===void 0||o.focus())}function je(){k.forEach((t,o)=>{we(o)&&t.syncPosition()})}function j(t){const{"onUpdate:value":o,onUpdateValue:i}=e,{nTriggerFormInput:v,nTriggerFormChange:S}=r;i&&L(i,t),o&&L(o,t),D.value=t,v(),S()}function ye(t){const{range:o}=e;if(o){if(Array.isArray(t)){const{value:i}=I;t.join()!==i.join()&&j(t)}}else Array.isArray(t)||I.value[0]!==t&&j(t)}function he(t,o){if(e.range){const i=I.value.slice();i.splice(o,1,t),ye(i)}else ye(t)}function F(t,o,i){const v=i!==void 0;i||(i=t-o>0?1:-1);const S=xe.value||[],{step:R}=e;if(R==="mark"){const V=q(t,S.concat(o),v?i:void 0);return V?V.value:o}if(R<=0)return o;const{value:H}=l;let P;if(v){const V=Number((o/R).toFixed(H)),G=Math.floor(V),Ae=V>G?G:G-1,Ee=V<G?G:G+1;P=q(o,[Number((Ae*R).toFixed(H)),Number((Ee*R).toFixed(H)),...S],i)}else{const V=Oe(t);P=q(t,[...S,V])}return P?Y(P.value):o}function Y(t){return Math.min(e.max,Math.max(e.min,t))}function ne(t){const{max:o,min:i}=e;return(t-i)/(o-i)*100}function He(t){const{max:o,min:i}=e;return i+(o-i)*t}function Oe(t){const{step:o,min:i}=e;if(Number(o)<=0||o==="mark")return t;const v=Math.round((t-i)/o)*o+i;return Number(v.toFixed(l.value))}function q(t,o=xe.value,i){if(!(o!=null&&o.length))return null;let v=null,S=-1;for(;++S<o.length;){const R=o[S]-t,H=Math.abs(R);(i===void 0||R*i>0)&&(v===null||H<v.distance)&&(v={index:S,distance:H,value:o[S]})}return v}function oe(t){const o=m.value;if(!o)return;const i=st(t)?t.touches[0]:t,v=o.getBoundingClientRect();let S;return e.vertical?S=(v.bottom-i.clientY)/v.height:S=(i.clientX-v.left)/v.width,e.reverse&&(S=1-S),He(S)}function fe(t){if(a.value||!e.keyboard)return;const{vertical:o,reverse:i}=e;switch(t.key){case"ArrowUp":t.preventDefault(),ke(o&&i?-1:1);break;case"ArrowRight":t.preventDefault(),ke(!o&&i?-1:1);break;case"ArrowDown":t.preventDefault(),ke(o&&i?1:-1);break;case"ArrowLeft":t.preventDefault(),ke(!o&&i?1:-1);break}}function ke(t){const o=U.value;if(o===-1)return;const{step:i}=e,v=I.value[o],S=Number(i)<=0||i==="mark"?v:v+i*t;he(F(S,v,t>0?1:-1),o)}function ut(t){var o,i;if(a.value||!st(t)&&t.button!==xn)return;const v=oe(t);if(v===void 0)return;const S=I.value.slice(),R=e.range?(i=(o=q(v,S))===null||o===void 0?void 0:o.index)!==null&&i!==void 0?i:-1:0;R!==-1&&(t.preventDefault(),Fe(R),ht(),he(F(v,I.value[R]),R))}function ht(){b.value||(b.value=!0,e.onDragstart&&L(e.onDragstart),ze("touchend",document,_e),ze("mouseup",document,_e),ze("touchmove",document,Ce),ze("mousemove",document,Ce))}function Se(){b.value&&(b.value=!1,e.onDragend&&L(e.onDragend),$e("touchend",document,_e),$e("mouseup",document,_e),$e("touchmove",document,Ce),$e("mousemove",document,Ce))}function Ce(t){const{value:o}=U;if(!b.value||o===-1){Se();return}const i=oe(t);i!==void 0&&he(F(i,I.value[o]),o)}function _e(){Se()}function ft(t){U.value=t,a.value||(M.value=t)}function vt(t){U.value===t&&(U.value=-1,Se()),M.value===t&&(M.value=-1)}function pt(t){M.value=t}function mt(t){M.value===t&&(M.value=-1)}qe(U,(t,o)=>void We(()=>de.value=o)),qe(re,()=>{if(e.marks){if(E.value)return;E.value=!0,We(()=>{E.value=!1})}We(je)}),Et(()=>{Se()});const Je=B(()=>{const{self:{markFontSize:t,railColor:o,railColorHover:i,fillColor:v,fillColorHover:S,handleColor:R,opacityDisabled:H,dotColor:P,dotColorModal:V,handleBoxShadow:G,handleBoxShadowHover:Ae,handleBoxShadowActive:Ee,handleBoxShadowFocus:gt,dotBorder:bt,dotBoxShadow:xt,railHeight:wt,railWidthVertical:yt,handleSize:kt,dotHeight:St,dotWidth:Ct,dotBorderRadius:_t,fontSize:zt,dotBorderActive:$t,dotColorPopover:Tt},common:{cubicBezierEaseInOut:Rt}}=p.value;return{"--n-bezier":Rt,"--n-dot-border":bt,"--n-dot-border-active":$t,"--n-dot-border-radius":_t,"--n-dot-box-shadow":xt,"--n-dot-color":P,"--n-dot-color-modal":V,"--n-dot-color-popover":Tt,"--n-dot-height":St,"--n-dot-width":Ct,"--n-fill-color":v,"--n-fill-color-hover":S,"--n-font-size":zt,"--n-handle-box-shadow":G,"--n-handle-box-shadow-active":Ee,"--n-handle-box-shadow-focus":gt,"--n-handle-box-shadow-hover":Ae,"--n-handle-color":R,"--n-handle-size":kt,"--n-opacity-disabled":H,"--n-rail-color":o,"--n-rail-color-hover":i,"--n-rail-height":wt,"--n-rail-width-vertical":yt,"--n-mark-font-size":t}}),ae=g?Pe("slider",void 0,Je,e):void 0,Ze=B(()=>{const{self:{fontSize:t,indicatorColor:o,indicatorBoxShadow:i,indicatorTextColor:v,indicatorBorderRadius:S}}=p.value;return{"--n-font-size":t,"--n-indicator-border-radius":S,"--n-indicator-box-shadow":i,"--n-indicator-color":o,"--n-indicator-text-color":v}}),se=g?Pe("slider-indicator",void 0,Ze,e):void 0;return{mergedClsPrefix:c,namespace:s,uncontrolledValue:D,mergedValue:re,mergedDisabled:a,mergedPlacement:Ue,isMounted:Wt(),adjustedTo:Ge(e),dotTransitionDisabled:E,markInfos:ce,isShowTooltip:we,shouldKeepTooltipTransition:De,handleRailRef:m,setHandleRefs:w,setFollowerRefs:z,fillStyle:te,getHandleStyle:ue,activeIndex:U,arrifiedValues:I,followerEnabledIndexSet:T,handleRailMouseDown:ut,handleHandleFocus:ft,handleHandleBlur:vt,handleHandleMouseEnter:pt,handleHandleMouseLeave:mt,handleRailKeyDown:fe,indicatorCssVars:g?void 0:Ze,indicatorThemeClass:se==null?void 0:se.themeClass,indicatorOnRender:se==null?void 0:se.onRender,cssVars:g?void 0:Je,themeClass:ae==null?void 0:ae.themeClass,onRender:ae==null?void 0:ae.onRender}},render(){var e;const{mergedClsPrefix:c,themeClass:s,formatTooltip:g}=this;return(e=this.onRender)===null||e===void 0||e.call(this),f("div",{class:[`${c}-slider`,s,{[`${c}-slider--disabled`]:this.mergedDisabled,[`${c}-slider--active`]:this.activeIndex!==-1,[`${c}-slider--with-mark`]:this.marks,[`${c}-slider--vertical`]:this.vertical,[`${c}-slider--reverse`]:this.reverse}],style:this.cssVars,onKeydown:this.handleRailKeyDown,onMousedown:this.handleRailMouseDown,onTouchstart:this.handleRailMouseDown},f("div",{class:`${c}-slider-rail`},f("div",{class:`${c}-slider-rail__fill`,style:this.fillStyle}),this.marks?f("div",{class:[`${c}-slider-dots`,this.dotTransitionDisabled&&`${c}-slider-dots--transition-disabled`]},this.markInfos.map(p=>f("div",{key:p.label,class:[`${c}-slider-dot`,{[`${c}-slider-dot--active`]:p.active}],style:p.style}))):null,f("div",{ref:"handleRailRef",class:`${c}-slider-handles`},this.arrifiedValues.map((p,m)=>{const $=this.isShowTooltip(m);return f(an,null,{default:()=>[f(sn,null,{default:()=>f("div",{ref:this.setHandleRefs(m),class:`${c}-slider-handle-wrapper`,tabindex:this.mergedDisabled?-1:0,style:this.getHandleStyle(p,m),onFocus:()=>{this.handleHandleFocus(m)},onBlur:()=>{this.handleHandleBlur(m)},onMouseenter:()=>{this.handleHandleMouseEnter(m)},onMouseleave:()=>{this.handleHandleMouseLeave(m)}},Ye(this.$slots.thumb,()=>[f("div",{class:`${c}-slider-handle`})]))}),this.tooltip&&f(ln,{ref:this.setFollowerRefs(m),show:$,to:this.adjustedTo,enabled:this.showTooltip&&!this.range||this.followerEnabledIndexSet.has(m),teleportDisabled:this.adjustedTo===Ge.tdkey,placement:this.mergedPlacement,containerClass:this.namespace},{default:()=>f(Kt,{name:"fade-in-scale-up-transition",appear:this.isMounted,css:this.shouldKeepTooltipTransition(m),onEnter:()=>{this.followerEnabledIndexSet.add(m)},onAfterLeave:()=>{this.followerEnabledIndexSet.delete(m)}},{default:()=>{var w;return $?((w=this.indicatorOnRender)===null||w===void 0||w.call(this),f("div",{class:[`${c}-slider-handle-indicator`,this.indicatorThemeClass,`${c}-slider-handle-indicator--${this.mergedPlacement}`],style:this.indicatorCssVars},typeof g=="function"?g(p):p)):null}})})]})})),this.marks?f("div",{class:`${c}-slider-marks`},this.markInfos.map(p=>f("div",{key:p.label,class:`${c}-slider-mark`,style:p.style},p.label))):null))}}),yn=h("switch",`
 height: var(--n-height);
 min-width: var(--n-width);
 vertical-align: middle;
 user-select: none;
 -webkit-user-select: none;
 display: inline-flex;
 outline: none;
 justify-content: center;
 align-items: center;
`,[x("children-placeholder",`
 height: var(--n-rail-height);
 display: flex;
 flex-direction: column;
 overflow: hidden;
 pointer-events: none;
 visibility: hidden;
 `),x("rail-placeholder",`
 display: flex;
 flex-wrap: none;
 `),x("button-placeholder",`
 width: calc(1.75 * var(--n-rail-height));
 height: var(--n-rail-height);
 `),h("base-loading",`
 position: absolute;
 top: 50%;
 left: 50%;
 transform: translateX(-50%) translateY(-50%);
 font-size: calc(var(--n-button-width) - 4px);
 color: var(--n-loading-color);
 transition: color .3s var(--n-bezier);
 `,[et({left:"50%",top:"50%",originalTransform:"translateX(-50%) translateY(-50%)"})]),x("checked, unchecked",`
 transition: color .3s var(--n-bezier);
 color: var(--n-text-color);
 box-sizing: border-box;
 position: absolute;
 white-space: nowrap;
 top: 0;
 bottom: 0;
 display: flex;
 align-items: center;
 line-height: 1;
 `),x("checked",`
 right: 0;
 padding-right: calc(1.25 * var(--n-rail-height) - var(--n-offset));
 `),x("unchecked",`
 left: 0;
 justify-content: flex-end;
 padding-left: calc(1.25 * var(--n-rail-height) - var(--n-offset));
 `),A("&:focus",[x("rail",`
 box-shadow: var(--n-box-shadow-focus);
 `)]),_("round",[x("rail","border-radius: calc(var(--n-rail-height) / 2);",[x("button","border-radius: calc(var(--n-button-height) / 2);")])]),tt("disabled",[tt("icon",[_("rubber-band",[_("pressed",[x("rail",[x("button","max-width: var(--n-button-width-pressed);")])]),x("rail",[A("&:active",[x("button","max-width: var(--n-button-width-pressed);")])]),_("active",[_("pressed",[x("rail",[x("button","left: calc(100% - var(--n-offset) - var(--n-button-width-pressed));")])]),x("rail",[A("&:active",[x("button","left: calc(100% - var(--n-offset) - var(--n-button-width-pressed));")])])])])])]),_("active",[x("rail",[x("button","left: calc(100% - var(--n-button-width) - var(--n-offset))")])]),x("rail",`
 overflow: hidden;
 height: var(--n-rail-height);
 min-width: var(--n-rail-width);
 border-radius: var(--n-rail-border-radius);
 cursor: pointer;
 position: relative;
 transition:
 opacity .3s var(--n-bezier),
 background .3s var(--n-bezier),
 box-shadow .3s var(--n-bezier);
 background-color: var(--n-rail-color);
 `,[x("button-icon",`
 color: var(--n-icon-color);
 transition: color .3s var(--n-bezier);
 font-size: calc(var(--n-button-height) - 4px);
 position: absolute;
 left: 0;
 right: 0;
 top: 0;
 bottom: 0;
 display: flex;
 justify-content: center;
 align-items: center;
 line-height: 1;
 `,[et()]),x("button",`
 align-items: center; 
 top: var(--n-offset);
 left: var(--n-offset);
 height: var(--n-button-height);
 width: var(--n-button-width-pressed);
 max-width: var(--n-button-width);
 border-radius: var(--n-button-border-radius);
 background-color: var(--n-button-color);
 box-shadow: var(--n-button-box-shadow);
 box-sizing: border-box;
 cursor: inherit;
 content: "";
 position: absolute;
 transition:
 background-color .3s var(--n-bezier),
 left .3s var(--n-bezier),
 opacity .3s var(--n-bezier),
 max-width .3s var(--n-bezier),
 box-shadow .3s var(--n-bezier);
 `)]),_("active",[x("rail","background-color: var(--n-rail-color-active);")]),_("loading",[x("rail",`
 cursor: wait;
 `)]),_("disabled",[x("rail",`
 cursor: not-allowed;
 opacity: .5;
 `)])]),kn=Object.assign(Object.assign({},le.props),{size:{type:String,default:"medium"},value:{type:[String,Number,Boolean],default:void 0},loading:Boolean,defaultValue:{type:[String,Number,Boolean],default:!1},disabled:{type:Boolean,default:void 0},round:{type:Boolean,default:!0},"onUpdate:value":[Function,Array],onUpdateValue:[Function,Array],checkedValue:{type:[String,Number,Boolean],default:!0},uncheckedValue:{type:[String,Number,Boolean],default:!1},railStyle:Function,rubberBand:{type:Boolean,default:!0},onChange:[Function,Array]});let me;const O=ge({name:"Switch",props:kn,setup(e){me===void 0&&(typeof CSS<"u"?typeof CSS.supports<"u"?me=CSS.supports("width","max(1px)"):me=!1:me=!0);const{mergedClsPrefixRef:c,inlineThemeDisabled:s}=Ne(e),g=le("Switch","-switch",yn,Lt,e,c),p=lt(e),{mergedSizeRef:m,mergedDisabledRef:$}=p,w=N(e.defaultValue),k=Ve(e,"value"),z=rt(k,w),T=B(()=>z.value===e.checkedValue),r=N(!1),a=N(!1),l=B(()=>{const{railStyle:b}=e;if(b)return b({focused:a.value,checked:T.value})});function D(b){const{"onUpdate:value":E,onChange:X,onUpdateValue:te}=e,{nTriggerFormInput:ce,nTriggerFormChange:ue}=p;E&&L(E,b),te&&L(te,b),X&&L(X,b),w.value=b,ce(),ue()}function Ie(){const{nTriggerFormFocus:b}=p;b()}function re(){const{nTriggerFormBlur:b}=p;b()}function I(){e.loading||$.value||(z.value!==e.checkedValue?D(e.checkedValue):D(e.uncheckedValue))}function be(){a.value=!0,Ie()}function Ue(){a.value=!1,re(),r.value=!1}function xe(b){e.loading||$.value||b.key===" "&&(z.value!==e.checkedValue?D(e.checkedValue):D(e.uncheckedValue),r.value=!1)}function U(b){e.loading||$.value||b.key===" "&&(b.preventDefault(),r.value=!0)}const de=B(()=>{const{value:b}=m,{self:{opacityDisabled:E,railColor:X,railColorActive:te,buttonBoxShadow:ce,buttonColor:ue,boxShadowFocus:we,loadingColor:De,textColor:Fe,iconColor:je,[Z("buttonHeight",b)]:j,[Z("buttonWidth",b)]:ye,[Z("buttonWidthPressed",b)]:he,[Z("railHeight",b)]:F,[Z("railWidth",b)]:Y,[Z("railBorderRadius",b)]:ne,[Z("buttonBorderRadius",b)]:He},common:{cubicBezierEaseInOut:Oe}}=g.value;let q,oe,fe;return me?(q=`calc((${F} - ${j}) / 2)`,oe=`max(${F}, ${j})`,fe=`max(${Y}, calc(${Y} + ${j} - ${F}))`):(q=Ke((W(F)-W(j))/2),oe=Ke(Math.max(W(F),W(j))),fe=W(F)>W(j)?Y:Ke(W(Y)+W(j)-W(F))),{"--n-bezier":Oe,"--n-button-border-radius":He,"--n-button-box-shadow":ce,"--n-button-color":ue,"--n-button-width":ye,"--n-button-width-pressed":he,"--n-button-height":j,"--n-height":oe,"--n-offset":q,"--n-opacity-disabled":E,"--n-rail-border-radius":ne,"--n-rail-color":X,"--n-rail-color-active":te,"--n-rail-height":F,"--n-rail-width":Y,"--n-width":fe,"--n-box-shadow-focus":we,"--n-loading-color":De,"--n-text-color":Fe,"--n-icon-color":je}}),M=s?Pe("switch",B(()=>m.value[0]),de,e):void 0;return{handleClick:I,handleBlur:Ue,handleFocus:be,handleKeyup:xe,handleKeydown:U,mergedRailStyle:l,pressed:r,mergedClsPrefix:c,mergedValue:z,checked:T,mergedDisabled:$,cssVars:s?void 0:de,themeClass:M==null?void 0:M.themeClass,onRender:M==null?void 0:M.onRender}},render(){const{mergedClsPrefix:e,mergedDisabled:c,checked:s,mergedRailStyle:g,onRender:p,$slots:m}=this;p==null||p();const{checked:$,unchecked:w,icon:k,"checked-icon":z,"unchecked-icon":T}=m,r=!(Le(k)&&Le(z)&&Le(T));return f("div",{role:"switch","aria-checked":s,class:[`${e}-switch`,this.themeClass,r&&`${e}-switch--icon`,s&&`${e}-switch--active`,c&&`${e}-switch--disabled`,this.round&&`${e}-switch--round`,this.loading&&`${e}-switch--loading`,this.pressed&&`${e}-switch--pressed`,this.rubberBand&&`${e}-switch--rubber-band`],tabindex:this.mergedDisabled?void 0:0,style:this.cssVars,onClick:this.handleClick,onFocus:this.handleFocus,onBlur:this.handleBlur,onKeyup:this.handleKeyup,onKeydown:this.handleKeydown},f("div",{class:`${e}-switch__rail`,"aria-hidden":"true",style:g},J($,a=>J(w,l=>a||l?f("div",{"aria-hidden":!0,class:`${e}-switch__children-placeholder`},f("div",{class:`${e}-switch__rail-placeholder`},f("div",{class:`${e}-switch__button-placeholder`}),a),f("div",{class:`${e}-switch__rail-placeholder`},f("div",{class:`${e}-switch__button-placeholder`}),l)):null)),f("div",{class:`${e}-switch__button`},J(k,a=>J(z,l=>J(T,D=>f(Xt,null,{default:()=>this.loading?f(Yt,{key:"loading",clsPrefix:e,strokeWidth:20}):this.checked&&(l||a)?f("div",{class:`${e}-switch__button-icon`,key:l?"checked-icon":"icon"},l||a):!this.checked&&(D||a)?f("div",{class:`${e}-switch__button-icon`,key:D?"unchecked-icon":"icon"},D||a):null})))),J($,a=>a&&f("div",{key:"checked",class:`${e}-switch__checked`},a)),J(w,a=>a&&f("div",{key:"unchecked",class:`${e}-switch__unchecked`},a)))))}}),Sn=e=>(en("data-v-da662465"),e=e(),tn(),e),Cn={class:"bg-slate-200 dark:bg-zinc-900 rounded-[10px] p-[8px] overflow-auto"},_n=Sn(()=>d("div",{class:"text-slate-500 mb-[5px] font-bold"}," LOGO ",-1)),zn={class:"flex items-center mt-[5px]"},$n={class:"text-slate-500 mb-[5px] font-bold"},Tn={class:"flex items-center mt-[5px]"},Rn={class:"mr-[10px]"},Bn={class:"text-slate-500 mb-[5px] font-bold"},Pn={class:"flex items-center mt-[5px]"},Vn={class:"mr-[10px]"},Mn={key:0,class:"flex items-center mt-[5px]"},Nn={class:"mr-[10px]"},In={class:"text-slate-500 mb-[5px] font-bold"},Un={class:"flex items-center mt-[5px]"},Dn={class:"mr-[10px]"},Fn={key:0,class:"flex items-center mt-[5px]"},jn={class:"mr-[10px]"},Hn={key:1,class:"flex items-center mt-[5px]"},On={class:"mr-[10px]"},An={class:"text-slate-500 mb-[5px] font-bold"},En={class:"mt-[5px]"},Wn={class:"flex items-center mt-[5px]"},Kn={key:0,class:"mt-[5px]"},Ln={class:"flex items-center mt-[5px]"},Xn={key:1,class:"mt-[5px]"},Yn={class:"flex items-center mt-[5px]"},qn={class:"mt-[5px]"},Gn={class:"flex items-center mt-[5px]"},Jn={class:"text-slate-500 mb-[5px] font-bold"},Zn={class:"text-shadow text-white"},Qn={class:"flex items-center mt-[5px]"},eo={class:"mr-[10px]"},to={key:0,class:"mt-1"},no={class:"flex items-center mt-[10px]"},oo={class:"mr-[10px]"},ao={class:"flex items-center mt-[10px]"},so={class:"mr-[10px]"},io={class:"text-slate-500 mb-[5px] font-bold"},lo={class:"flex items-center mt-[5px]"},ro={class:"mr-[10px]"},co={class:"flex items-center mt-[10px]"},uo={class:"mr-[10px]"},ho={class:"flex"},fo={class:"flex items-center mt-[10px]"},vo={class:"mr-[10px]"},po={class:"flex items-center mt-[10px]"},mo={class:"mr-[10px]"},go={class:"flex items-center mt-[10px]"},bo={class:"mr-[10px]"},xo={class:"text-slate-500 mb-[5px] font-bold"},wo=ge({__name:"index",setup(e){const c=qt(),s=Gt(),g=Jt(),p=N(!1),m=N(!1),$=[{label:Te("apps.baseSettings.detailIcon"),value:Re.info},{label:Te("apps.baseSettings.smallIcon"),value:Re.icon}],w=[{label:"px",value:"px"},{label:"%",value:"%"}];qe(s.panelConfig,()=>{m.value||(m.value=!0,setTimeout(()=>{s.recordState(),m.value=!1,z()},1e3))});function k({file:r,event:a}){const l=JSON.parse((a==null?void 0:a.target).response);return s.panelConfig.backgroundImageSrc=l.data.imageUrl,r}function z(){Zt({panel:s.panelConfig}).then(r=>{r.code===0?g.success(Te("apps.baseSettings.configSaved")):g.error(Te("apps.baseSettings.configFailed",{message:r.msg}))})}function T(){s.resetPanelConfig(),z()}return(r,a)=>(Q(),ee("div",Cn,[u(n(K),{style:{"border-radius":"10px"},size:"small"},{default:C(()=>[_n,d("div",null,[d("div",null,y(r.$t("apps.baseSettings.textContent")),1),d("div",zn,[u(n(Be),{value:n(s).panelConfig.logoText,"onUpdate:value":a[0]||(a[0]=l=>n(s).panelConfig.logoText=l),type:"text","show-count":"",maxlength:20,placeholder:"请输入文字"},null,8,["value"])])])]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",$n,y(r.$t("apps.baseSettings.clock")),1),d("div",Tn,[d("span",Rn,y(r.$t("apps.baseSettings.clockSecondShow")),1),u(n(O),{value:n(s).panelConfig.clockShowSecond,"onUpdate:value":a[1]||(a[1]=l=>n(s).panelConfig.clockShowSecond=l)},null,8,["value"])])]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",Bn,y(r.$t("apps.baseSettings.searchBar")),1),d("div",Pn,[d("span",Vn,y(r.$t("common.show")),1),u(n(O),{value:n(s).panelConfig.searchBoxShow,"onUpdate:value":a[2]||(a[2]=l=>n(s).panelConfig.searchBoxShow=l)},null,8,["value"])]),n(s).panelConfig.searchBoxShow?(Q(),ee("div",Mn,[d("span",Nn,y(r.$t("apps.baseSettings.searchBarSearchItem")),1),u(n(O),{value:n(s).panelConfig.searchBoxSearchIcon,"onUpdate:value":a[3]||(a[3]=l=>n(s).panelConfig.searchBoxSearchIcon=l)},null,8,["value"])])):ie("",!0)]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",In,y(r.$t("apps.baseSettings.systemMonitorStatus")),1),d("div",Un,[d("span",Dn,y(r.$t("common.show")),1),u(n(O),{value:n(s).panelConfig.systemMonitorShow,"onUpdate:value":a[4]||(a[4]=l=>n(s).panelConfig.systemMonitorShow=l)},null,8,["value"])]),n(s).panelConfig.systemMonitorShow?(Q(),ee("div",Fn,[d("span",jn,y(r.$t("apps.baseSettings.showTitle")),1),u(n(O),{value:n(s).panelConfig.systemMonitorShowTitle,"onUpdate:value":a[5]||(a[5]=l=>n(s).panelConfig.systemMonitorShowTitle=l)},null,8,["value"])])):ie("",!0),n(s).panelConfig.systemMonitorShow?(Q(),ee("div",Hn,[d("span",On,y(r.$t("apps.baseSettings.publicVisitModeShow")),1),u(n(O),{value:n(s).panelConfig.systemMonitorPublicVisitModeShow,"onUpdate:value":a[6]||(a[6]=l=>n(s).panelConfig.systemMonitorPublicVisitModeShow=l)},null,8,["value"])])):ie("",!0)]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",An,y(r.$t("common.icon")),1),d("div",En,[d("div",null,y(r.$t("common.style")),1),d("div",Wn,[u(n(ot),{value:n(s).panelConfig.iconStyle,"onUpdate:value":a[7]||(a[7]=l=>n(s).panelConfig.iconStyle=l),options:$},null,8,["value"])])]),n(s).panelConfig.iconStyle===n(Re).info?(Q(),ee("div",Kn,[d("div",null,y(r.$t("apps.baseSettings.hideDescription")),1),d("div",Ln,[u(n(O),{value:n(s).panelConfig.iconTextInfoHideDescription,"onUpdate:value":a[8]||(a[8]=l=>n(s).panelConfig.iconTextInfoHideDescription=l)},null,8,["value"])])])):ie("",!0),n(s).panelConfig.iconStyle===n(Re).icon?(Q(),ee("div",Xn,[d("div",null,y(r.$t("apps.baseSettings.hideTitle")),1),d("div",Yn,[u(n(O),{value:n(s).panelConfig.iconTextIconHideTitle,"onUpdate:value":a[9]||(a[9]=l=>n(s).panelConfig.iconTextIconHideTitle=l)},null,8,["value"])])])):ie("",!0),d("div",qn,[d("div",null,y(r.$t("common.textColor")),1),d("div",Gn,[u(n(rn),{value:n(s).panelConfig.iconTextColor,"onUpdate:value":a[10]||(a[10]=l=>n(s).panelConfig.iconTextColor=l),"show-alpha":!1,size:"small",modes:["hex"],swatches:["#000000","#ffffff","#18A058","#2080F0","#F0A020"]},null,8,["value"])])])]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",Jn,y(r.$t("apps.baseSettings.wallpaper")),1),u(n(dn),{action:"/api/file/uploadImg","show-file-list":!1,name:"imgfile",headers:{token:n(c).token},"directory-dnd":!0,onFinish:k},{default:C(()=>[u(n(cn),{style:{width:"100%"}},{default:C(()=>[d("div",{class:"h-[200px] w-full border bg-slate-100 flex justify-center items-center cursor-pointer rounded-[10px]",style:Qt({background:`url(${n(s).panelConfig.backgroundImageSrc}) no-repeat`,backgroundSize:"cover"})},[d("div",Zn,y(r.$t("apps.baseSettings.uploadOrDragText")),1)],4)]),_:1})]),_:1},8,["headers"]),d("div",Qn,[d("span",eo,y(r.$t("apps.baseSettings.customImageAddress")),1),u(n(O),{value:p.value,"onUpdate:value":a[11]||(a[11]=l=>p.value=l)},null,8,["value"])]),p.value?(Q(),ee("div",to,[u(n(Be),{value:n(s).panelConfig.backgroundImageSrc,"onUpdate:value":a[12]||(a[12]=l=>n(s).panelConfig.backgroundImageSrc=l),type:"text",size:"small",clearable:""},null,8,["value"])])):ie("",!0),d("div",no,[d("span",oo,y(r.$t("apps.baseSettings.vague")),1),u(n(pe),{value:n(s).panelConfig.backgroundBlur,"onUpdate:value":a[13]||(a[13]=l=>n(s).panelConfig.backgroundBlur=l),class:"max-w-[200px]",step:2,max:20},null,8,["value"])]),d("div",ao,[d("span",so,y(r.$t("apps.baseSettings.mask")),1),u(n(pe),{value:n(s).panelConfig.backgroundMaskNumber,"onUpdate:value":a[14]||(a[14]=l=>n(s).panelConfig.backgroundMaskNumber=l),class:"max-w-[200px]",step:.1,max:1},null,8,["value","step"])])]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",io,y(r.$t("apps.baseSettings.contentArea")),1),u(n(hn),{cols:"2"},{default:C(()=>[u(n(ve),{span:"12 400:12"},{default:C(()=>[d("div",lo,[d("span",ro,y(r.$t("apps.baseSettings.netModeChangeButtonShow")),1),u(n(O),{value:n(s).panelConfig.netModeChangeButtonShow,"onUpdate:value":a[15]||(a[15]=l=>n(s).panelConfig.netModeChangeButtonShow=l)},null,8,["value"])])]),_:1}),u(n(ve),{span:"12 400:12"},{default:C(()=>[d("div",co,[d("span",uo,y(r.$t("apps.baseSettings.maxWidth")),1),d("div",ho,[u(n(un),null,{default:C(()=>[u(n(Be),{value:n(s).panelConfig.maxWidth,"onUpdate:value":a[16]||(a[16]=l=>n(s).panelConfig.maxWidth=l),size:"small",type:"number",maxlength:10,style:{width:"100px"},placeholder:"1200"},null,8,["value"]),u(n(ot),{value:n(s).panelConfig.maxWidthUnit,"onUpdate:value":a[17]||(a[17]=l=>n(s).panelConfig.maxWidthUnit=l),style:{width:"80px"},options:w,size:"small"},null,8,["value"])]),_:1})])])]),_:1}),u(n(ve),{span:"12 400:12"},{default:C(()=>[d("div",fo,[d("span",vo,y(r.$t("apps.baseSettings.leftRightMargin")),1),u(n(pe),{value:n(s).panelConfig.marginX,"onUpdate:value":a[18]||(a[18]=l=>n(s).panelConfig.marginX=l),class:"max-w-[200px]",step:1,max:100},null,8,["value"])])]),_:1}),u(n(ve),{span:"12 400:12"},{default:C(()=>[d("div",po,[d("span",mo,y(r.$t("apps.baseSettings.topMargin"))+" (%)",1),u(n(pe),{value:n(s).panelConfig.marginTop,"onUpdate:value":a[19]||(a[19]=l=>n(s).panelConfig.marginTop=l),class:"max-w-[200px]",step:1,max:50},null,8,["value"])])]),_:1}),u(n(ve),{span:"12 400:6"},{default:C(()=>[d("div",go,[d("span",bo,y(r.$t("apps.baseSettings.bottomMargin"))+" (%)",1),u(n(pe),{value:n(s).panelConfig.marginBottom,"onUpdate:value":a[20]||(a[20]=l=>n(s).panelConfig.marginBottom=l),class:"max-w-[200px]",step:1,max:50},null,8,["value"])])]),_:1})]),_:1})]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[d("div",xo,y(r.$t("apps.baseSettings.customFooter")),1),u(n(Be),{value:n(s).panelConfig.footerHtml,"onUpdate:value":a[21]||(a[21]=l=>n(s).panelConfig.footerHtml=l),type:"textarea",clearable:""},null,8,["value"])]),_:1}),u(n(K),{style:{"border-radius":"10px"},class:"mt-[10px]",size:"small"},{default:C(()=>[u(n(gn),{onPositiveClick:T},{trigger:C(()=>[u(n(Me),{size:"small",quaternary:"",type:"error"},{default:C(()=>[Xe(y(r.$t("common.reset")),1)]),_:1})]),default:C(()=>[Xe(" "+y(r.$t("apps.baseSettings.resetWarnText")),1)]),_:1}),u(n(Me),{size:"small",quaternary:"",type:"success",class:"ml-[10px]",onClick:z},{default:C(()=>[Xe(y(r.$t("common.save")),1)]),_:1})]),_:1})]))}});const $o=fn(wo,[["__scopeId","data-v-da662465"]]);export{$o as default};
