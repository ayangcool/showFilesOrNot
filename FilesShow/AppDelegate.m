//
//  AppDelegate.m
//  FilesShow
//
//  Created by chenghxc on 13-3-7.
//  Copyright (c) 2013年 Wondershare. All rights reserved.
//

#import "AppDelegate.h"
@interface AppDelegate()
@property (nonatomic,retain) IBOutlet NSMenu *menu;
-(IBAction)showAllFiles:(id)sender;
-(IBAction)hideAllFiles:(id)sender;
-(IBAction)exit:(id)sender;

-(void) addAppAsLoginItem;
-(void) deleteAppFromLoginItem;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize menu = _menu;

- (void)dealloc
{
    [self setMenu:nil];
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self addAppAsLoginItem];
    // Insert code here to initialize your application
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem *statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"eye.png"]];
    [statusItem setMenu:self.menu];
    [statusItem setHighlightMode:YES];
    [statusItem retain];
}

-(IBAction)showAllFiles:(id)sender{
    system("defaults write com.apple.finder AppleShowAllFiles  YES");
    system("killall Finder");
}

-(IBAction)hideAllFiles:(id)sender{
    system("defaults write com.apple.finder AppleShowAllFiles  NO");
    system("killall Finder");
}

-(IBAction)exit:(id)sender{
    [NSApp terminate:self]; 
}

-(void) addAppAsLoginItem{
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    //获取程序的路径
    // 比如, /Applications/test.app
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    // 创建路径的引用
    // 我们只为当前用户添加启动项,所以我们用kLSSharedFileListSessionLoginItems
    // 如果要为全部用户添加,则替换为kLSSharedFileListGlobalLoginItems
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        //将项目插入启动表中.
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,kLSSharedFileListItemLast, NULL, NULL,url, NULL, NULL);
        if (item){
            CFRelease(item);
        }
    }
    CFRelease(loginItems);
}


-(void) deleteAppFromLoginItem{
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    //获取程序的路径
    // 比如, /Applications/test.app
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    // 创建引用.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seedValue;
        //获取启动项列表并转换为NSArray,这样方便取其中的项
        NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        for(int i = 0;i< [loginItemsArray count];i++){
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            //用URL来解析项
            if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(NSURL*)url path];
                if ([urlPath compare:appPath] == NSOrderedSame){
                    LSSharedFileListItemRemove(loginItems,itemRef);
                }
            }
        }
        [loginItemsArray release];
    }
    
}
@end
