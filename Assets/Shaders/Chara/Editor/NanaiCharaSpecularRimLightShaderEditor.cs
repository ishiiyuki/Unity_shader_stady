using UnityEngine;
using UnityEditor;
using System;

public sealed class NanaiCharaSpecularRimLightShaderEditor : ShaderGUI
{

    MaterialProperty mainTexture;
    MaterialProperty ambientColor;
    MaterialProperty diffuseRate;
    MaterialProperty specularRate;
    MaterialProperty rimThickness;
    MaterialProperty rimColor;

    MaterialProperty stencilMask;
    MaterialProperty stencilCompareMode;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
    
        mainTexture = FindProperty("_MainTex", properties);
        ambientColor = FindProperty("_AmbColor", properties);
        diffuseRate = FindProperty("_DiffuseRate", properties);
        specularRate = FindProperty("_SpecularRate", properties);
        rimThickness = FindProperty("_RimThick", properties);
        rimColor = FindProperty("_RimColor", properties);
        stencilMask = FindProperty("_Mask", properties);
        stencilCompareMode = FindProperty("_CompareMode", properties);

        EditorGUIUtility.labelWidth = 0f;

        EditorGUI.BeginChangeCheck();
        {

        }
        EditorGUI.EndChangeCheck();


        materialEditor.TexturePropertySingleLine(new GUIContent(mainTexture.displayName, "Main Color Texture (RGB)"), mainTexture);
        materialEditor.ColorProperty(ambientColor, ambientColor.displayName);
        materialEditor.RangeProperty(diffuseRate, diffuseRate.displayName);
        materialEditor.RangeProperty(specularRate, specularRate.displayName);
        materialEditor.RangeProperty(rimThickness, rimThickness.displayName);
        materialEditor.ColorProperty(rimColor, rimColor.displayName);

        materialEditor.FloatProperty(stencilMask, stencilMask.displayName);
        int currentCompareMode = (int)stencilCompareMode.floatValue;
        int newCompareMode = EditorGUILayout.Popup(stencilCompareMode.displayName, currentCompareMode, Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction)));
        if(currentCompareMode != newCompareMode)
        {
            stencilCompareMode.floatValue = (float)newCompareMode;
        }
        materialEditor.RenderQueueField();
    }
}    