# diatopics
Diachronic Topic Modeling (using Mallet)

Mit dem Shell- und R-Script können Belege aus einem Korpus, die eine Datumsangabe haben, mit Mallet (LDA-Topic-Modeling) verarbeitet und die diachrone Verteilung der Cluster anschließend visualisiert werden.

Die Methode ist beschrieben in:

Bubenhofer, Noah (2018): Diskurslinguistik und Korpora. In: Warnke, Ingo (Hrsg.): Handbuch Diskurs, Sprachwissen. Berlin / New York: De Gruyter, S. 208-241, DOI: 10.1515/9783110296075-009. https://www.degruyter.com/view/books/9783110296075/9783110296075-009/9783110296075-009.xml

Und:
https://www.bubenhofer.com/sprechtakel/2013/03/06/die-semantik-von-terrorismus-lda-topic-modelling/

## Anleitung

### Voraussetzungen

* System, auf dem sh-Scripte ausgeführt werden können (Unix/Linux/Mac OS X)
* installiertes Mallet: http://mallet.cs.umass.edu
* installiertes R: http://www.r-project.org

Als Inputdaten dienen Korpusbelege, die im folgenden Format vorliegen müssen:

~~~~
    50625: <text_date 1947-01-11>:  d Ruhe in Palästina wieder herstellen . vor d Kabinettssitzung ergehen er|es|sie|Sie d englisch Presse in Mutmaßung über d Erklärung d Belagerungszustand und d Sicherstellung alle , d verdächtig sein , zur Irgun-Zvai-Leuni oder zur Sternbande zu gehören . Ben Gurion , d Vorsitzende d Jewish Agency in Palästina , haben von Basel ein Abstecher nach London machen und nun nach sein Heimat ein Ultimatum - mitbekommen . darin werden ein eindeutig Stellungnahme sein Organisation gegen d Terrorist und für d Zusammenarbeit mit d Behörde verlangen . d englisch Presse stützen d Regierung und ermuntern sie , unmittelbar gegen d <Terror> vorgehen . " absolut Festigkeit sein d einzig Art , wie man Terrorist behandeln können " , schreiben " Sunday Times " . zu d Notwendigkeit ein akut Befriedung kommen d ander ein Lösung d politisch Problem Palästina . theoretisch geben es dafür drei Möglichkeit : d erst bestehen darin , er|es|sie|Sie aus Palästina zurückziehen . d heißen , d zahlenmäßig schwach Jude d Araber preisgeben . d zweit haben Churchill bereits an d Wand malen : d Mandat an d UNO als Nachfolgerin d Völkerbund zurückgeben . d sein ein Geste hilflos Resignation . bleiben praktisch nur d dritt
   117118: <text_date 1947-02-01>:  an d " Manier d Diktator " gemahnen . Lord Pakenham werden noch deutlich . " d jugoslawisch Forderung entbehren jed Grundlage " , sagen er im Oberhaus . " Sie|sie|sie sein nicht d Papier wert , auf d sie schreiben werden . " soweit es d Haltung England und auch d vereinigt Staat angehen , scheinen er|es|sie|Sie wieder einmal d sprichwörtlich Glück Oesterreichs* ) zu bewahrheiten . nur Rußland befürworten d Gebietsanspruch Jugoslawien . *)Tu felix Austria nube - glücklich Oesterreich , heiraten ! jahrhundertelang werden dies Sprichwort auf d erfolgreich Heiratspolitik d Habsburger anwenden . __UNDEF__ __UNDEF__ teuer <Terror> Skalpjäger am Jordan d jüdisch Untergrundbewegung in Palästina haben ihr Tätigkeit verstärken , weil sie spüren , daß ein Kompromiß , d nicht unbedingt ihr Wunsch entsprechen , näherrücken . dies sein d Meinung d " Manchester Guardian " , und d gewaltsam Entführung zweier britisch Untertan|Untertane , d Gerichtspräsident Windham und d Major Harry Collins , geben dies Meinung recht . beide werden unter geradezu abenteuerlich Umstand gekidnapped . Richter Windham werden in Talar und Perücke innerhalb von zwei Minute aus d Gerichtssaal entführen , Major Collins von vier bewaffnet Jude , darunter ein Mädchen , chloroformieren und aus
~~~~

### Export aus CWB:

Wenn die CWB (http://cwb.sourceforge.net) verwendet wird, können diese Belege so erzeugt werden (vorausgesetzt, es gibt ein Metadatum "text_date"):

~~~~
set Context 25 words;
set PrintStructures "text_date";
show -pos -word +lemma;

[lemma="USA"]; 
cat Last > "inputfile.txt"; 
~~~~

Hier werden anstelle der Wortformen die Lemmata (Grundformen) verwendet. Das kann natürlich angepasst werden, indem man z.B. nur die Wortformen berücksichtigt.

### Verarbeitung mit Mallet und R über sh-Script

Das Script `cwb2ldaTopics.sh` übernimmt die Verarbeitung der Inputdaten und ruft das R-Script `generateLDAGraphs.r` auf, um die Grafiken zu erzeugen.

~~~~
./cwb2ldaTopics.sh 20 path/to/inputfile.txt
~~~~

Erster Parameter ist die Anzahl zu berechnende Topics, zweiter Parameter der Pfad zur Belegedatei.
