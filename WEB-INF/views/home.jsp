<%@page session="true"%><%@taglib uri="http://www.springframework.org/tags" prefix="sp"%><%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%><html version="XHTML+RDFa 1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/1999/xhtml http://www.w3.org/MarkUp/SCHEMA/xhtml-rdfa-2.xsd" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/">
<head data-color="${colorPair}" profile="http://www.w3.org/1999/xhtml/vocab">
<title>${results.getTitle()}&mdash;Min Mod</title>
<jsp:include page="inc/header.jsp"></jsp:include>
</head>
<body id="top">
	<article>
		<div id="logoBanner">
    			<img src="${conf.getStaticResourceURL()}img/minmod-logo.png" alt="MinMod Logo" id="logoImage">&nbsp;&nbsp;&nbsp;&nbsp;
    			<div id="minmod-logo"><a href="https://minmod.isi.edu/"><span>Min Mod</span></a></div>
		</div>
		<header>
			<hgroup>
                                <h1>
					<span style="font-size: 30px;font-family: 'Source Code Pro', monospace;" >Min Mod</span>
				</h1>
				<h2>Extracting Models of Minerals from Knowledge</h2>
			</hgroup>
                        <!--
			<div id="abstract">
				<div class="value">TODO</div>
			</div>
                        -->
		</header>

		<aside class="empty"></aside>

		<div id="directs" style="font-size:20px; line-height: normal;">
			<div id="abstract">This web application serves as a <a href="https://www.w3.org/standards/semanticweb/data" target="_blank">linked open data</a> browser and hosts a <a href="https://www.w3.org/TR/sparql11-query/" target="_blank">SPARQL</a> endpoint.<br><br>
<a href="https://minmod.isi.edu/resource/httpsw3idorgusgsz4530692r8gbbqjn1.html" style="font-size:25px;color:#990000">Start browsing the data!</a><br><br>
The browser retrieves the RDF data from our SPARQL endpoint here: <a href="https://minmod.isi.edu/sparql" target="_blank">https://minmod.isi.edu/sparql</a>.</div>
		</div>

		<div id="inverses" class="empty"></div> 
		<jsp:include page="inc/custom_footer.jsp"></jsp:include>
	</article>
	<jsp:include page="inc/footer.jsp"></jsp:include>

</body>
</html>
