<%@page session="true"%><%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%><%@taglib uri="http://www.springframework.org/tags" prefix="sp"%><footer>
	<div id="download">
                Data from: <a href="https://minmod.isi.edu/sparql" style="color: #FFFFFF">https://minmod.isi.edu/sparql</a><br>
                <a href="https://github.com/DARPA-CRITICALMAAS/schemas/tree/main/ta2" target="_blank" style="color:#FDC93F" >The data follows this schema (github)</a><br>
                <br>
		Powered by <a href="https://github.com/dvcama/LodView" id="linkBack" target="_blank"></a>
	</div>
	<div id="endpoint" align="right">
                <div>
			<div style="padding-bottom: 0px"><a href="https://usc-isi-i2.github.io" style="color: ##D3D3D3;font-size: 22px;font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;" target="_blank">Center on<br>Knowledge Graphs</a></div>
                 <div><a href="http://www.isi.edu" target="_blank"><img src="${conf.getStaticResourceURL()}img/ISI_Brand_Logo_Yellow_White_RGB.png" alt="ISI-Brand-Logo-Yellow-White" style='max-height:100px' ></a></div>
            </div>
	</div>
</footer>
<c:if test="${not empty conf.getLicense()}">
	<div id="license">
		<div>${conf.getLicense()}</div>
	</div>
</c:if>
