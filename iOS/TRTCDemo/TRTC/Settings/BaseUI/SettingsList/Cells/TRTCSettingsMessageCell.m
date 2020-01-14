/*
* Module:   TRTCSettingsMessageCell
*
* Function: 配置列表Cell，右侧是一个输入框和一个发送Button，用于消息发送
*
*/

#import "TRTCSettingsMessageCell.h"
#import "UIButton+TRTC.h"
#import "UITextField+TRTC.h"
#import "Masonry.h"

@interface TRTCSettingsMessageCell ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *messageText;
@property (strong, nonatomic) UIButton *sendButton;

@end

@implementation TRTCSettingsMessageCell

- (void)setupUI {
    [super setupUI];
    
    self.sendButton = [UIButton trtc_cellButtonWithTitle:@"发送"];
    [self.sendButton addTarget:self action:@selector(onClickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-18);
    }];
    
    self.messageText = [UITextField trtc_textFieldWithDelegate:self];
    [self.contentView addSubview:self.messageText];
    [self.messageText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.sendButton.mas_leading).offset(-5);
        make.width.mas_equalTo(120);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTextChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.messageText];
}

- (void)onClickSendButton:(id)sender {
    TRTCSettingsMessageItem *item = (TRTCSettingsMessageItem *)self.item;
    if (item.action) {
        item.action(self.messageText.text ?: @"");
    }
    [self.messageText resignFirstResponder];
}

- (void)onTextChange {
    TRTCSettingsMessageItem *messageItem = (TRTCSettingsMessageItem *)self.item;
    messageItem.content = self.messageText.text;
}

- (void)didUpdateItem:(TRTCSettingsBaseItem *)item {
    TRTCSettingsMessageItem *messageItem = (TRTCSettingsMessageItem *)item;
    [self.sendButton setTitle:messageItem.actionTitle forState:UIControlStateNormal];
    self.messageText.text = messageItem.content;
    self.messageText.attributedPlaceholder = [UITextField trtc_textFieldPlaceHolderFor:messageItem.placeHolder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end


@implementation TRTCSettingsMessageItem

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                       action:(void (^)(NSString * _Nullable content))action {
    return [self initWithTitle:title placeHolder:placeHolder content:nil actionTitle:@"发送" action:action];
}

- (instancetype)initWithTitle:(NSString *)title
                  placeHolder:(NSString *)placeHolder
                      content:(NSString * _Nullable)content
                  actionTitle:(nonnull NSString *)actionTitle
                       action:(void (^)(NSString * _Nullable content))action {
    if (self = [super init]) {
        self.title = title;
        _placeHolder = placeHolder;
        _content = content;
        _actionTitle = actionTitle;
        _action = action;
    }
    return self;
}

+ (Class)bindedCellClass {
    return [TRTCSettingsMessageCell class];
}

- (NSString *)bindedCellId {
    return [TRTCSettingsMessageItem bindedCellId];
}

@end

