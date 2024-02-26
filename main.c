#include <stdio.h>
#include <android_native_app_glue.h>

#define CNFG_IMPLEMENTATION
#include "CNFG.h"

void HandleKey( int keycode, int bDown ) { }
void HandleButton( int x, int y, int button, int bDown ) { }
void HandleMotion( int x, int y, int mask ) { }

void HandleResume() {}
void HandleSuspend() {}
int HandleDestroy() { return 0; }

int main(int argc, char ** argv)
{
	CNFGSetupFullscreen( "Seed", 0);

	while(CNFGHandleInput())
	{
		CNFGBGColor = 0x000080ff;

		// short w, h;
		CNFGClearFrame();
		// CNFGGetDimensions( &w, &h );

		CNFGColor( 0xffffffff ); 

		// CNFGPenX = 10; CNFGPenY = 10;
		CNFGDrawText( "Hello, World", 50 );

		// CNFGTackPixel( 30, 30 );         

		// CNFGTackSegment( 50, 50, 100, 50 );

		// CNFGColor( 0x800000ff ); 

		// CNFGTackRectangle( 100, 50, 150, 100 ); 

		// RDPoint points[3] = { { 30, 36 }, { 20, 50 }, { 40, 50 } };
		// CNFGTackPoly( points, 3 );

		// {
		// 	static uint32_t data[64*64];
		// 	int x, y;

		// 	for( y = 0; y < 64; y++ ) for( x = 0; x < 64; x++ )
		// 		data[x+y*64] = 0xff | (rand()<<8);

		// 	CNFGBlitImage( data, 120, 190, 64, 64 );
		// }

		CNFGSwapBuffers();		
	}

	printf("exiting\n");
}
