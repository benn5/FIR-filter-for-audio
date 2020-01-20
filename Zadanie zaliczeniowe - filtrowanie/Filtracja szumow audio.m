## wstepne wyczyszczenie wszystki okien i innych rzeczy
clear all;
close all;
clf;
pkg load signal;

## wczytanie sygnalu dzwiekowego
## s - sygna� d�wi�kowy
## fp czestotliwosc sygna�u = 44100 Hz - mozna zobaczy� np. w Audacity
[s,fp]=auload('bird.wav'); 


## liczba probek sygnalu dzwiekowego(ok. 80000)- jego dlugosc
## plik z cwierkaniem ptaszka ma dlugosc okolo 1.78s * 44100Hz ~ 78K
t_lenght=length(s); 

## wektor kolejnych probek od 1 do 78588 o skoku jednostokowym
t=1:t_lenght; 

 
## mno�nik osi Y wykresu
amp = 10.0; 
## przemnozenie wyresu 
s(1:t_lenght) = amp * s(1:t_lenght); 


## liczba bit�w przetwornika - zaproponowana na zaj�ciach
## mo�e ich byc wiecej w celu uleopszenia sygnalu
BITS = 5;


## petla for dla zapisywania kolejnych iteracji
## wykresow i plikow dzwiekowych n=(od 1 do ilio�ci bit�w przetwornika)
for n = 1:BITS;


## parametr "a" aktualnie a = 3 
## n = 2; 
a = 2^n - 1; 

## zaokroglenie sygnalu do wielkosci okrelonej przez dobrane prze z nas "a"
signal_quantized = round(s(1:t_lenght) * a) / a;

## szum = r�nica sygna�u oryg. od syg. skwantowanego zaokoglonego
noise = s(1:t_lenght) - signal_quantized; 


## wydrukowanie przebiegu sygna��w: oryginalnego, skatyzowanego i 
## szumu w zalezno�ci od czasu na jednym wykresie - w roznych kolorach
## niebieski "-b" - oryginalny
## zielony "-g" - spr�bkowany
## czerwony "-r" - szum
plot(t, s(1:t_lenght), '-b; Sygna� oryginalny;',
    t, signal_quantized, '-g; Sygna� spr�bkowany;',
    t, noise, '-r; B��d pr�bkowania;');
    
## grid - siateczka pomocnicza na wykresie  
grid on;
xlabel('Czas [nr skwantownej pr�bki]'); 
ylabel('Amplituda [-]'); 
step = int2str(n);
title({"Pojedynczy krok kwantyzacji nr. ", step}); 



## (n, :) - oznacza �e rz�dy n maj� byc w calosci wczytane
## std - zwraca odchylenie standardowe sygna�u
## skala logarytmiczna pomnozona przez 20 co oznacza analize napieciowa???
## t_lenght to jes ilo�� probek ~78K pr�bek dla cz�totliwosci 44100Hz pliku audio
signal_deviation(n,:) = 20 * log10( std( s(1:t_lenght) ) / std(noise) ); 


## int2str - konwertuje integer na string
## wydrukowanie zjdecia Kwantowy sygnal z numerem "i" iteracji petli for do rozszerzenia .png
print(['Kwanowy sygnal ', int2str(n),'.png'],"-dpng","-color"); 

signal_rounded = round(s * a) / a;

## zapisanie pliku audio pojedynczego kroku iteracji
ausave(['bird', int2str(n), '.wav'], signal_rounded, fp); 

## koniec petli for
end
##


################################################################################
################################################################################
##DRUGA RAMKA Z WYKRESAMI


## wykres sygna�u w czasie pomno�ony przez amp 
##(amplitude dobrana na poczatku zadania) - ilo�c kolumn = t_lenght
## figure - nowe okno z wykresem

subplot(3,3,1);
plot(t, s(1:t_lenght), '-b');

title('Sygna� wejsciowy'); 
xlabel('Czas [nr skwantownej pr�bki]'); 
ylabel('Amplituda [-]');
hold on; grid on;


## wykres przedstawiaj�cy SNR w zale�nosci od ilosci bit�w przetwornika
## im wiecej bitow tym lepsze rozdzielenie sygnalu od szumu
## SNR oznacza stosunek sgna�u do szumu (signal/noise rratio)
## "r*" oznacza iz kolejne probki beda zaznaczone joko kropki na wykresie
## "b-" oznacza niebieska linie ��cz�ca kropki
subplot(3,3,3);
plot(signal_deviation, 'r*');
hold on; 
plot(signal_deviation,'b-'); 
hold on; grid on; 

title({'SNR: syg./szum w zale�no�ci', 'od ilo�ci bit�w przetwornika'}); 
ylabel({'Warto�� stosunku', 'sygna�u do szumu [dB]'}); 
xlabel('Ilo�� bit�w przetwornika [szt.]'); 

## ilo�� pierwiastkow rowniania: od 1, wzrastaj� co 1 do liczby BITS
n_poly = 1:1:BITS;


## funkcja polyfit zwracaj�ca pierwiastki r�wnania o najlepszym dopasowaniu
## znak ' za wektorem n_poly zmienia kolumny na rz�dy tak aby dopasowa�
## wymiary wektor�w zmiennych do siebie
## 1 oznacza wektor logiczny ustawiaj�cy uzycia pierwiastk�w rowanania na true
polyfit(n_poly', signal_deviation, 1);



% Przykladowe pytania na zliczenie:
% - co to jest filtracja
% - transformata Fouriera
% - transformata Hilberta - po co sie stosuje
% - co to jest modulacja (ktora wynika przeciez z transformaty hilberta)
% - jak j� uzyska�




## stworzenie pliku adio BITS+1 bedacego kopia pliku BITS
## w celu umozliwienia nieprzerwanego dzialania programu - jak tak sie nie zrobi
## to program sie sypie
file1 = ['bird' , int2str(BITS), '.wav'];
file2 = ['bird' , int2str(BITS + 1), '.wav'];
copyfile(file1, file2);


## analiza widma sygna�u po kwantowaniu - bird_(BITS+1).wav
[s_final,fp] = auload(file2); 

## z poprzednich rozwarzan: fp=44100 Hz
N=fp/2;

## funkcja wyznaczaj�ca minimalna potege dw�jki zeby 2^x by�o wieksze
## niz nasze fp wybranego pliku

    Nf_help = 1;
    help = 2;
    while(help < N)
        help = help* 2;
        Nf_help++;
    endwhile
    ##


## potega dwojki woeksz niz nasze fp
Nf=2^Nf_help;


## Nf2 = ilo�c kolumn dla transformaty Fouriera
## dwukrotnie mniejsza z uwagi na wlasciwosci transformaty
## TFF jest symetryczna wzgledem osi Y
Nf2=Nf/2 + 1;


## wector z rowno rozlozonymi elementami cz�stotliwosci
## od 0  do Nf2 = 16385
f=linspace(0, fp/2, Nf2);


## wykres samego sygnalu bez szumu po iteracyjnym pr�bkowaniu
## s_final jest to sygnal po i-tym probkowaniu
subplot(3,3,4);
plot(t,  s_final(1:t_lenght));
title({'Sygna� spr�bkowany', '- bez szumu'}); 
xlabel('Czas [nr skwantownej pr�bki]'); 
ylabel('Amplituda [-]');
hold on; grid on;


## transformata FFT dyskretna dla sygna�u po iteracyjnym pr�bkowaniu
s_ftt = fft(s_final,Nf)


## modu� widma sygnalu po iteracyjnym pr�bkowaniu
s_ftt_abs = abs(s_ftt);

subplot(3,3,5);
plot(f,s_ftt_abs(1:Nf2));
title({"Modu� widma sygnalu po", "iteracyjnym pr�bkowaniu"});
xlabel('Cz�stotliwo�� [Hz]');
ylabel({'Modu� widma sygna�u po', 'iteracyjnym pr�bkowaniu [-]'});
box off; grid on;


## faza sygnalu po iteracyjnym pr�bkowaniu
s_fft_angle = angle(s_ftt);

subplot(3,3,6);
plot(f, s_fft_angle(1:Nf2));
title({"Faza sygnalu po", "iteracyjnym pr�bkowaniu"});
xlabel('Cz�stotliwo�� [Hz]');
ylabel('K�t fazowy sygna�u [rad]');
box off; grid on; axis tight;



## wykres sygna�u szumu
subplot(3,3,7);
plot(t,  noise(1:t_lenght));
title('Szum pr�bkowania'); 
xlabel('Czas [nr skwantownej pr�bki]'); 
ylabel('Amplituda [-]');
hold on; grid on;


## FFT dla sygna�u szumu po iteracyjnym pr�bkowaniu
## wyznaczamy FFt dla szumu zeby zobaczyc na jakich
## czestotliwosciach on wystepuje - zeby moc go wyciac z pliku audio
noise_fft = fft(noise, Nf)
noise_fft_abs=abs(noise_fft);


## modu� widma sygna�u szumu po iteracyjnym pr�bkowaniu
subplot(3,3,8);
plot(f, noise_fft_abs(1:Nf2));
title("Modu� widma szumu");
xlabel('Cz�stotliwo�� [Hz]');
ylabel('Modu� widma szumu [-]');
grid on; hold on;


## faza szumu po zastosowaniu redukcji szum�w
noise_ftt_angle = angle(noise_fft);

subplot(3,3,9);
plot(f, noise_ftt_angle(1:Nf2));
title("Faza szumu");
xlabel('Cz�stotliwo�� [Hz]');
ylabel('K�t fazowy sygna�u [rad]');
grid on; hold on;


## zapisanie wykresow jako zdjecia o rozmiarze 1600x900 pixeli
## dla pozostalych figur analogicznie
print(['Fig. 1 - Wykresy sygnalu oryginalnego, sprobkowanego i szumu.png'], "-dpng", '-S1600,900'); 


#############################################################################
#############################################################################
##TRZECIA RAMKA Z WYKRESAMI


## FILTR FIR
## czestotliw odciecia [Hz] - zakres dobrany na podstawie poprzednich wykres�w
## dla roznych plikow audio beda to rozne zakresy czestotliowsci szumu
## w przypadku pliku burd1.wav najlepszym moim zdaniem dopasowaniem jest 
## filtr typu bandpass
freqCut = [2200 2900];

## czestotliwosc znormalizowana
wc = freqCut / (fp/2);

## wspolczynniki filtra FIR
firCoeff = fir1(128, wc, 'bandpass');


##nowa ramka z wykresami
figure;
subplot(2,3,4);
## wykres slupkowy
stem(firCoeff);
title("Wsp�czynniki filtra");
hold on;


## sygnal pliku audio s_final po redukcji szumu filtrowany z opoznieniem
s_filtered = filter(firCoeff, 1, s_final);


subplot(2,3,1);
plot(t, s_filtered, '-r', 
     t, s_final, '-b');

title("Sygna� audio - filtr z op�nieniem: \n czerwony - syg. oryginalny, \n niebieski - syg. przefiltrowany");
xlabel('Czas [nr skwantownej pr�bki]'); 
ylabel('Sygna� [-]');
grid on; hold on;


## FFT dla przefiltrowanego audio s_filtered w zakresie
## czestotliwosci od 0 do Nf2
s_filtered_fft = fft(s_filtered, Nf2);

## modu� widma sygnalu po zastosowaniu filtra odcinajacego
s_filtered_fft_abs = abs(s_filtered_fft);

subplot(2,3,2);
plot(f,s_filtered_fft_abs(1:Nf2));
title({"Modu� widma sygna�u po" , "zastosowaniu filtra", "odcinaj�cego"});
xlabel('Cz�stotliwo�� [Hz]');
ylabel('Modu� widma szumu po jego redukcji [-]');
grid on; hold on;


## faza sygnalu po zastosowaniu filtra odcinajacego
s_filtered_fft_angle = angle(s_filtered_fft);

subplot(2,3,3);
plot(f, s_filtered_fft_angle(1:Nf2));
title({"Faza sygna�u po", "zastosowaniu filtra odcin�jacego"});
xlabel('Cz�stotliwo�� [Hz]');
ylabel('K�t fazowy sygna�u [rad]');
grid on; hold on;


## odworzenie pliku audio
player = audioplayer (s_filtered, fp);
play (player);

## zapisanie pliku audio xxx_filtered.wav
ausave(['bird_filtered.wav'], s_filtered, fp); 



## odpowiedz czestotliwosciowa filtra FIR
[H,f]=freqz(firCoeff, 1, 2^Nf_help, fp);

subplot(2,3,5);
plot(f,abs(H));
title({"Odpowied�", "cz�stotliwo�ciowa"});
xlabel('Cz�stotliwo�� [Hz]')'
ylabel('Odpowied� cz�stotliwo�ciowa [-]');
grid on; hold on;

## faza odpowiedzi czestotliowsciowej filtra FIR
subplot(2,3,6);
plot(f,angle(H));
title({"Faza odpowiedzi", "cz�stotliwo�ciowej"});
xlabel('Cz�stotliwo�� [Hz]');
ylabel('K�t fazowy sygna�u [rad]');
grid on; hold on;


## zapisanie wykresow jako zdjecia
print(['Fig. 2 -  ykresy filtra FIR.png'],"-dpng", '-S1600,900'); 


##############################################################################
##############################################################################
## TRZECIA RAMKA Z WYKRESAMI


## odpowiedz czestotliwosciowa filtra FIR w decybelach
## pokazana na nowej ramce z dwoma wykresami
## faza i magnituda t�umienia wybranych cz�totliwosci
figure;
freqz(firCoeff, 1, 2^Nf_help, fp);


## zapisanie wykresow jako zdjecia
print(['Fig. 3 - Wykresy odpowiedzi czestotliwosciowej filtra FIR.png'],"-dpng", '-S1600,900'); 











