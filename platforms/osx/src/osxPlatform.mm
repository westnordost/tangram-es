#include"appleAllowedFonts.h"
#include "osxPlatform.h"
#include "gl/hardware.h"
#include "log.h"
#include "platform_gl.h"

#import <cstdarg>
#import <cstdio>
#import <map>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>

namespace Tangram {

void logMsg(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
}

void setCurrentThreadPriority(int priority) {
    // POSIX thread priority is between -20 (highest) and 19 (lowest),
    // NSThread priority is between 0.0 (lowest) and 1.0 (highest).
    double p = (20 - priority) / 40.0;
    [[NSThread currentThread] setThreadPriority:p];
}

void initGLExtensions() {
    Tangram::Hardware::supportsMapBuffer = true;
}

void OSXPlatform::requestRender() const {
    glfwPostEmptyEvent();
}

void decodeImageData(NSData* data, ImageUrlResponse& response) {
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (!imageSourceRef) {
        response.error = "CGImageSourceCreateWithData failed";
        return;
    }
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);
    if (!imageRef) {
        response.error = "CGImageSourceCreateImageAtIndex failed";
        return;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceRef) {
        response.error = "CGColorSpaceCreateDeviceRGB failed";
        return;
    }

    constexpr const size_t bitsPerComponent = 8;
    constexpr const size_t bytesPerPixel = 4;
    const size_t bytesPerRow = bytesPerPixel * width;
    response.data.resize(bytesPerRow * height);
    CGContextRef contextRef = CGBitmapContextCreate(response.data.data(), width, height, bitsPerComponent, bytesPerRow,
                                                    colorSpaceRef, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    if (!contextRef) {
        response.error = "CGBitmapContextCreate failed";
        return;
    }
    CGContextSetBlendMode(contextRef, kCGBlendModeCopy);
    CGContextTranslateCTM(contextRef, 0.0, height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    response.width = width;
    response.height = height;

    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    CFRelease(imageSourceRef);
}

OSXPlatform::OSXPlatform() {
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/tile_cache"];
    NSURLCache *tileCache = [[NSURLCache alloc] initWithMemoryCapacity: 4 * 1024 * 1024 diskCapacity: 30 * 1024 * 1024 diskPath: cachePath];
    configuration.URLCache = tileCache;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.timeoutIntervalForRequest = 30;
    configuration.timeoutIntervalForResource = 60;

    m_urlSession = [NSURLSession sessionWithConfiguration: configuration];
}

OSXPlatform::~OSXPlatform() {
    [m_urlSession getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        for(NSURLSessionTask* task in dataTasks) {
            [task cancel];
        }
    }];
}

std::vector<FontSourceHandle> OSXPlatform::systemFontFallbacksHandle() const {
    std::vector<FontSourceHandle> handles;

    NSFontManager *manager = [NSFontManager sharedFontManager];
    NSArray<NSString *> *fallbacks = [manager availableFontFamilies];

    handles.reserve([fallbacks count]);

    for (NSString* fallback in fallbacks) {
        if (!allowedFamily(fallback)) { continue; }

        for (NSArray* familyFont in [manager availableMembersOfFontFamily:fallback]) {
            NSString* fontName = familyFont[0];
            NSString* fontStyle = familyFont[1];
            if ( ![fontName containsString:@"-"] || [fontStyle isEqualToString:@"Regular"]) {
                handles.emplace_back(std::string(fontName.UTF8String));
                break;
            }
        }
    }

    return handles;
}

FontSourceHandle OSXPlatform::systemFont(const std::string& _name, const std::string& _weight, const std::string& _face) const {
    static std::map<int, CGFloat> weightTraits = {
        {100, NSFontWeightUltraLight},
        {100, NSFontWeightUltraLight},
        {200, NSFontWeightThin},
        {300, NSFontWeightLight},
        {400, NSFontWeightRegular},
        {500, NSFontWeightMedium},
        {600, NSFontWeightSemibold},
        {700, NSFontWeightBold},
        {800, NSFontWeightHeavy},
        {900, NSFontWeightBlack},
    };

    static std::map<std::string, NSFontSymbolicTraits> fontTraits = {
        {"italic", NSFontItalicTrait},
        {"bold", NSFontBoldTrait},
        {"expanded", NSFontExpandedTrait},
        {"condensed", NSFontCondensedTrait},
        {"monospace", NSFontMonoSpaceTrait},
    };

    NSFont* font = [NSFont fontWithName:[NSString stringWithUTF8String:_name.c_str()] size:1.0];

    if (font == nil) {
        // Get the default system font
        if (_weight.empty()) {
            font = [NSFont systemFontOfSize:1.0];
        } else {
            int weight = atoi(_weight.c_str());

            // Default to 400 boldness
            weight = (weight == 0) ? 400 : weight;

            // Map weight value to range [100..900]
            weight = std::min(std::max(100, (int)floor(weight / 100.0 + 0.5) * 100), 900);

            font = [NSFont systemFontOfSize:1.0 weight:weightTraits[weight]];
        }
    }

    if (_face != "regular") {
        NSFontSymbolicTraits traits;
        NSFontDescriptor* descriptor = [font fontDescriptor];

        auto it = fontTraits.find(_face);
        if (it != fontTraits.end()) {
            traits = it->second;

            // Create a new descriptor with the symbolic traits
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:traits];

            if (descriptor != nil) {
                font = [NSFont fontWithDescriptor:descriptor size:1.0];
            }
        }
    }

    return FontSourceHandle(std::string(font.fontName.UTF8String));
}

UrlRequestHandle OSXPlatform::startUrlRequest(Url _url, UrlCallback _callback) {

    void (^handler)(NSData*, NSURLResponse*, NSError*) = ^void (NSData* data, NSURLResponse* response, NSError* error) {

        // Create our response object. The '__block' specifier is to allow mutation in the data-copy block below.
        __block UrlResponse urlResponse;

        // Check for errors from NSURLSession, then check for HTTP errors.
        if (error != nil) {

            urlResponse.error = [error.localizedDescription UTF8String];

        } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int statusCode = [httpResponse statusCode];
            if (statusCode >= 400) {
                urlResponse.error = [[NSHTTPURLResponse localizedStringForStatusCode: statusCode] UTF8String];
            }
        }

        // Copy the data from the NSURLResponse into our URLResponse.
        // First we allocate the total data size.
        urlResponse.content.resize([data length]);
        // NSData may be stored in several ranges, so the 'bytes' method may incur extra copy operations.
        // To avoid that we copy the data in ranges provided by the NSData.
        [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
            memcpy(urlResponse.content.data() + byteRange.location, bytes, byteRange.length);
        }];

        // Run the callback from the requester.
        if (_callback) {
            _callback(urlResponse);
        }
    };

    NSURL* nsUrl = [NSURL URLWithString:[NSString stringWithUTF8String:_url.string().c_str()]];
    NSURLSessionDataTask* dataTask = [m_urlSession dataTaskWithURL:nsUrl completionHandler:handler];

    [dataTask resume];

    return [dataTask taskIdentifier];

}

UrlRequestHandle OSXPlatform::startImageUrlRequest(Tangram::Url _url, Tangram::ImageUrlCallback _callback) {
    void (^handler)(NSData*, NSURLResponse*, NSError*) = ^void (NSData* data, NSURLResponse* response, NSError* error) {

        // Create our response object. The '__block' specifier is to allow mutation in the data-copy block below.
        __block ImageUrlResponse urlResponse;

        // Check for errors from NSURLSession, then check for HTTP errors.
        if (error != nil) {

            urlResponse.error = [error.localizedDescription UTF8String];

        } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int statusCode = [httpResponse statusCode];
            if (statusCode >= 400) {
                urlResponse.error = [[NSHTTPURLResponse localizedStringForStatusCode: statusCode] UTF8String];
            }
        }

        // Decode the response data into pixel data.
        decodeImageData(data, urlResponse);

        // Run the callback from the requester.
        if (_callback) {
            _callback(urlResponse);
        }
    };

    NSURL* nsUrl = [NSURL URLWithString:[NSString stringWithUTF8String:_url.string().c_str()]];
    NSURLSessionDataTask* dataTask = [m_urlSession dataTaskWithURL:nsUrl completionHandler:handler];

    [dataTask resume];

    return [dataTask taskIdentifier];
}

void OSXPlatform::cancelUrlRequest(UrlRequestHandle handle) {

    [m_urlSession getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        for (NSURLSessionTask* task in dataTasks) {
            if ([task taskIdentifier] == handle) {
                [task cancel];
                break;
            }
        }
    }];
}

} // namespace Tangram
