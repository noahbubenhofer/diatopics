# Part of diatopics by Noah Bubenhofer
# 

args <- commandArgs(trailingOnly = T);
print(args);
file <- args[1];
lemma <- args[2];

# Definitionen
minUse <- 0.1; # Schwellenwert Mindestverwendung des Clusters in den Daten
minProb <- 0.1; # Schwellenwert Mindestwahrscheinlichkeit, dass der Beleg zur Gruppe gehört


# Daten einlesen
d <- read.table(paste0(file,".tab.simple.txt"), header=T, sep="\t", dec=".", colClasses=c("factor", "factor", "factor", "integer", "integer", "numeric"))
l <- read.table(paste0(file,".keys.txt"), header=F, sep="\t", colClasses=c("integer","numeric", "character"), dec=",");
attach(d)

# Keys verarbeiten
# wir speichern die Topic-Bezeichnungen; jeweils vier Wörter
# Wir filtern: Das Topic muss minUse häufig verwendet worden sein. Restliche Topics füllen wir mit NA
legendstring2 <- NULL;
(legendstring <- rep(NA, length(l)))
for (i in 1:length(l[[1]])) { 
	if (l[i,2] >= minUse) {
		legendstring[i] <- paste0(i, ": ",(paste(strsplit(l[i,3], " ")[[1]][1:4], sep="", collapse = " ")));
		legendstring2 <- c(legendstring2, paste0(i, ": ",(paste(strsplit(l[i,3], " ")[[1]][1:4], sep="", collapse = " "))));
	}
}
legendstring2 <- c(legendstring2, "andere");

# wir filtern die Daten und wollen nur die Topics, die bei der Verarbeitung der keys oben übrig geblieben sind. Bei den anderen schreiben wir NA rein als Restklasse
d_sel <- data.frame();
ii <- 1;
for (i in 1:dim(d)[1]) {
	if (!is.na(legendstring[(d[i,"Topic"]+1)])) {
		d_sel[ii,1] <- d[i,1];
		d_sel[ii,2] <- d[i,2];
		d_sel[ii,3] <- d[i,3];
		d_sel[ii,4] <- d[i,4];
		d_sel[ii,5] <- d[i,5];
		d_sel[ii,6] <- d[i,6];
	} else {
		d_sel[ii,1] <- d[i,1];
		d_sel[ii,2] <- d[i,2];
		d_sel[ii,3] <- d[i,3];
		d_sel[ii,4] <- d[i,4];
		d_sel[ii,5] <- NA;
		d_sel[ii,6] <- d[i,6];
	}
	ii <- ii+1;
}

# Erstellung der Kreuztabellen: einmal mit den ausgewählten Topics und einmal alle:
mytable_sel <- with(d_sel[d_sel$V6>=minProb,], table(V3, V5, useNA = c("always")));
mytable <- with(d[d$Probability>=minProb,], table(Year, Topic));

# Farben für die Darstellung
colors <- sample(rainbow(length(l[[1]]), alpha=.7));

# Ausgabe der Übersichtsgrafik, jeweils PNG und PDF und absolute und normalisierte Werte:
png(paste0(file,".png"), width=700, height=400, units="px")
par(mar=c(5.1,4.1,4.1,12), xpd=T)

if (lemma == "fulltext") {
	maintitle <- paste0("Verteilung der Topics");
} else {
	maintitle <- paste0("Verteilung semantisches Profil '",lemma,"'");
}

barplot(t(prop.table(mytable_sel,1)), col = c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), main=paste0("Verteilung semantisches Profil '",lemma,"'"), space=0, border=NA, sub=paste0("LDA-Klassifikation: '",lemma,"'"), cex.names=1, ylab="normalisierte Frequenzen")
legend("right", legendstring2, fill=c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), cex=.8, bg="white", inset=c(-0.3,0))
dev.off();


png(paste0(file,".abs.png"), width=700, height=400, units="px")
par(mar=c(5.1,4.1,4.1,12), xpd=T)

barplot(t(mytable_sel), col = c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), main=paste0("Verteilung semantisches Profil '",lemma,"'"), space=0, border=NA, sub=paste0("LDA-Klassifikation: '",lemma,"'"), cex.names=1, ylab="absolute Frequenz")
legend("right", legendstring2, fill=c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), cex=.8, bg="white", inset=c(-0.3,0))
dev.off();



pdf(paste0(file,".pdf"), width=9, height=5);
par(mar=c(5.1,4.1,4.1,12), xpd=T)
barplot(t(prop.table(mytable_sel,1)), col = c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), main=paste0("Verteilung semantisches Profil '",lemma,"'"), space=0, border=NA, sub=paste0("LDA-Klassifikation: '",lemma,"'"), cex.names=1, ylab="normalisierte Frequenzen")
legend("right", legendstring2, fill=c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), cex=.6, bg="white", inset=c(-0.3,0))

dev.off();

pdf(paste0(file,".abs.pdf"), width=9, height=5);
par(mar=c(5.1,4.1,4.1,12), xpd=T)
barplot(t(mytable_sel), col = c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), main=paste0("Verteilung semantisches Profil '",lemma,"'"), space=0, border=NA, sub=paste0("LDA-Klassifikation: '",lemma,"'"), cex.names=1, ylab="absolute Frequenz")
legend("right", legendstring2, fill=c(colors[1:(length(legendstring2)-1)], "#CCCCCC"), cex=.6, bg="white", inset=c(-0.3,0))

dev.off();

# Ausgabe der einzelnen Grafiken für die einzelnen Topics:
for (i in 1:length(l[[1]])) {
	print(paste(i, colors[i], sep=": "));
	
	if (lemma == "fulltext") {
		subtitle <- paste0("LDA-Klassifikation, Topic ", i, "/", length(l[[1]]), "");
	} else {
		subtitle <- paste0("LDA-Klassifikation in 50-Wort-Fenstern um '",lemma,"' herum, Topic ", i, "/", length(l[[1]]), "");
	}
		
	
	# PNG
	png(paste(file,"_",i,".png", sep=""), width=700, height=400, units="px");
	par(mar=c(5.1,4.1,4.1,2.1));
	barplot(prop.table(mytable,1)[,i], main=paste(strwrap(l[i,3],width=70),collapse="\n"), col = colors[i], sub=subtitle);
	dev.off();
	
	# PDF
	pdf(paste(file,"_",i,".pdf", sep=""), width=9, height=5);
	par(mar=c(5.1,4.1,4.1,2.1));
	barplot(prop.table(mytable,1)[,i], main=paste(strwrap(l[i,3],width=70),collapse="\n"), col = colors[i], sub=subtitle);
	dev.off();
}
detach(d);