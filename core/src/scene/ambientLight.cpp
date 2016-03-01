#include "ambientLight.h"

#include "glm/gtx/string_cast.hpp"
#include "platform.h"

namespace Tangram {

std::string AmbientLight::s_classBlock;
std::string AmbientLight::s_typeName = "AmbientLight";

AmbientLight::AmbientLight(const std::string& _name, bool _dynamic) :
    Light(_name, _dynamic) {

    m_type = LightType::ambient;

}

AmbientLight::~AmbientLight() {

}

std::unique_ptr<LightUniforms> AmbientLight::injectOnProgram(ShaderProgram& _shader) {
    Light::injectOnProgram(_shader);

    auto u = std::make_unique<LightUniforms>(_shader);

    auto name = getUniformName();
    u->ambient = name+".ambient";
    u->diffuse = name+".diffuse";
    u->specular = name+".specular";

    return u;
}

void AmbientLight::setupProgram(const View& _view, LightUniforms& _uniforms) {
    if (m_dynamic) {
        Light::setupProgram(_view, _uniforms);
    }
}

std::string AmbientLight::getClassBlock() {
    if (s_classBlock.empty()) {
        s_classBlock = stringFromFile("shaders/ambientLight.glsl", PathType::internal)+"\n";
    }
    return s_classBlock;
}

std::string AmbientLight::getInstanceDefinesBlock() {
    //  Ambient lights don't have defines.... yet.
    return "\n";
}

std::string AmbientLight::getInstanceAssignBlock() {
    std::string block = Light::getInstanceAssignBlock();
    if (!m_dynamic) {
        block += ")";
    }
    return block;
}

const std::string& AmbientLight::getTypeName() {

    return s_typeName;

}

}
