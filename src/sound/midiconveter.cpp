#include <bits/stdc++.h>
using namespace std;

#define FILL(X, V)           memset((X), (V), sizeof(X))
#define SIZE(V)              int((V).size())
#define FOR2(cont,start,max) for(int (cont) = (start), _MAX = (max); (cont) < _MAX; (cont)++)
#define FOR(cont,max)        FOR2((cont), 0, (max))
#define LOG(x)               (31 - __builtin_clz(x))
#define W(x)                 cerr << "\033[31m" << #x << " = '" << x << "'\033[0m" << endl;
#define Wx(x)                fprintf(stderr,"\033[31m"#x" = '0x%02x'\033[0m\n",x);
#define ii 					 pair<int, int>
#define ff 					 first
#define ss 					 second
#define oo 					 1e9
#define ep 					 1e-9
#define pb 					 push_back

typedef long long ll;
typedef unsigned long long ul;


#define CUR (*(unsigned char*)curBuffer)
char *buffer,*curBuffer;
uint lastType;

uint readVariableLenghtNumber(){
	unsigned char c;
	uint num = 0;
	while(1){
		c = CUR;curBuffer++;
		num <<= 7;
		num += c & ~0x80;
		if(!(c & 0x80))return num;
	}
}

uint readFixedLenghtNumber(uint cnt){
	uint num = 0;
	FOR(i,cnt){
		num <<= 8;
		num += CUR;
		curBuffer++;
	}
	return num;
}

string readFixedLenghtString(uint cnt){
	string s{curBuffer,cnt};
	curBuffer += cnt;
	return s;
}


struct trackEvent{
	uint deltaTime = 0;
	uint type = 0;
	uint data1 = 0;
	uint data2 = 0;
	trackEvent(){
		deltaTime = readVariableLenghtNumber();
		W(deltaTime);

		if(CUR < 0x80)type = lastType;//running status
		else type = readFixedLenghtNumber(1);

		while(type < 0x80)type = readFixedLenghtNumber(1);

		if(type >= 0x80 && type <= 0xef)lastType = type;
		if(type >= 0xf0 && type <= 0xf7)lastType = 0;

		if(type <= 0x9f){//note on/off
			data1 = readFixedLenghtNumber(1);
			data2 = readFixedLenghtNumber(1);
			if(type <= 0x8f)cerr << "Turn off note " << data1 << "," << data2 << endl;
			if(type >= 0x90)cerr << "Turn on  note " << data1 << "," << data2 << endl;
		}
		else if(type <= 0xbf)curBuffer += 2;//just ignore it
		else if(type <= 0xdf)curBuffer += 1;//just ignore it
		else if(type <= 0xef)curBuffer += 2;//just ignore it
		else if(type == 0xf0 || type == 0xf7)//system exclusive, ends with 0xf7
			while(readFixedLenghtNumber(1) != 0xf7);//just ignore it
		else if(type == 0xf2)curBuffer += 2;//just ignore it
		else if(type == 0xf3)curBuffer += 1;//just ignore it
		else if(type == 0xff){
			curBuffer++;
			uint lenght = readFixedLenghtNumber(1);
			W(lenght);
			curBuffer += lenght;
		}
	}
};


struct chunk{
	string type = "MT??";
	uint lenght = 0;
	chunk(){}
	virtual ~chunk(){}
};
struct chunkH : public chunk{
	ul format,ntrks,division;
	chunkH(uint l){
		type = "MThd";
		lenght = l;
		format = readFixedLenghtNumber(2);
		ntrks = readFixedLenghtNumber(2);
		division = readFixedLenghtNumber(2);

		W(type);
		W(lenght);
		W(format);
		W(ntrks);
		W(division);
	}
	virtual ~chunkH(){}
};
struct chunkT : public chunk{
	vector<trackEvent*> v;
	chunkT(uint l){
		type = "MTrk";
		lenght = l;

		W(type);
		W(lenght);

		char *beg = curBuffer;
		lastType = 0x00;
		while(curBuffer < beg + l){
			trackEvent *pt = new trackEvent();
			v.pb(pt);
		}
	}
	virtual ~chunkT(){ for(trackEvent* pt : v)delete pt; }
};

chunk* readChunk(){
	string type = readFixedLenghtString(4);
	uint lenght = readFixedLenghtNumber(4);
	if(type == "MThd")return new chunkH(lenght);
	if(type == "MTrk")return new chunkT(lenght);
	readFixedLenghtNumber(lenght);
	return nullptr;
}

int main(int argc, char **argv){
	if(argc < 2){
		cerr << "Modo de uso = './a.out arquivo.midi > out.txt'" << endl;
		return 0;
	}

	ifstream file(argv[1], std::ifstream::binary);
	if(file.is_open()){
		file.seekg(0, file.end);
		int length = file.tellg();
		file.seekg(0, file.beg);

		curBuffer = buffer = new char[length];

		file.read(buffer,length);
		file.close();
	}

	chunkH *header = (chunkH*)readChunk();
	vector<chunkT*> tracks;

	FOR(i,header->ntrks){
		chunk *c = readChunk();
		if(c && c->type == "MTrk")tracks.pb((chunkT*)c);
		else delete c;
	}
	delete[] buffer;


	map<uint,vector<tuple<uint,uint,uint>>> events;
	for(chunkT *t : tracks){
		uint curTime = 0;
		for(trackEvent *e : t->v){
			curTime += e->deltaTime;
			if(e->type <= 0x9f)events[curTime].pb(make_tuple(e->type,e->data1,e->data2));
		}
	}
	for(chunkT* t : tracks)delete t;

	map<uint,vector<tuple<uint,uint,uint>>> notes;
	map<uint,uint> on;
	for(auto it = events.rbegin(); it != events.rend(); it++){
		for(auto &ev : it->ss){
			uint type,data1,data2;
			tie(type,data1,data2) = ev;
			if(type < 0x90 || data2 == 0){
				//event to turn of note 'data1'
				if(on.count(data1))cerr << "Turning note " << data1 << " off twice, at times " << it->ff << " and " << on[data1] << endl;
				if(it->ff != 0)on[data1] = it->ff;//means it was on before
			}
			else{
				if(!on.count(data1))cerr << "Turning note " << data1 << " on at time " << it->ff << " without turning it off later on." << endl;
				else{
					//event to turn on note 'data1' with intensity 'data2', turn off at 'on[data1]'
					notes[it->ff].pb(make_tuple(data1,on[data1] - it->ff,data2));//note,duration,intensity
					on.erase(data1);
				}
			}
		}
	}
	for(auto &it : on)cerr << "Turning note " << it.ff << " off at " << it.ss << " without turning it on" << endl;


	uint note,duration,intensity,time,prevTime = 0,cont=0;
	for(auto &it : notes){
		time = it.ff;
		for(auto &it2 : it.ss){
			cont++;
			tie(note,duration,intensity) = it2;
			cout << time - prevTime << ", ";
			prevTime = time;
		}
	}
	cout << endl;

	for(auto &it : notes){
		time = it.ff;
		for(auto &it2 : it.ss){
			tie(note,duration,intensity) = it2;
			cout << note << ", ";
		}
	}
	cout << endl;


	for(auto &it : notes){
		time = it.ff;
		for(auto &it2 : it.ss){
			tie(note,duration,intensity) = it2;
			cout << duration << ", ";
		}
	}
	cout << endl;


	for(auto &it : notes){
		time = it.ff;
		for(auto &it2 : it.ss){
			tie(note,duration,intensity) = it2;
			cout << intensity << ", ";
		}
	}
	cout << endl;

	cout << cont << endl;

	delete header;

	return 0;
}
