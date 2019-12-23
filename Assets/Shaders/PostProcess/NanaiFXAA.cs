using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class NanaiFXAA : MonoBehaviour
{
    static readonly int ID_SHADERPARAM_EDGE_THRESHOLD_MIN = Shader.PropertyToID("_EdgeThresholdMin");
    static readonly int ID_SHADERPARAM_EDGE_THRESHOLD = Shader.PropertyToID("_EdgeThreshold");
    static readonly int ID_SHADERPARAM_EDGE_SHARPNESS = Shader.PropertyToID("_EdgeSharpness");

    [Header("FXAA : 右にスライドするほどクオリティが上がり速度が遅くなります")]
    // 0.0833 - upper limit (defaut, the start of visibuel unfilter)
    // 0.0625 - high quality
    // 0.0312 - visible limit (slower)
    [Range(0.0833f, 0.0312f)]
    public float edgeThresholdMin = 0.0625f;
    // 0.333 - too little (faster)
    // 0.250 - low quality
    // 0.166 - default
    // 0.125 - high quality
    // 0.063 - overlill (slower)
    [Range(0.333f, 0.063f)]
    public float edgeThreshold = 0.166f;
    // 8.0 is sharper (default)
    // 4.0 is softer
    // 2.0 is really soft ( good only for vector graphics inputs)
    [Range(8.0f, 2.0f)]
    public float edgeSharpness = 4.0f;

    Material material_ = null;
    Material FXAAMaterial
    {
        get
        {
            if (material_ == null)
            {
                material_ = new Material(FXAAShader);
                material_.hideFlags = HideFlags.DontSave;
            }
            return material_;
        }
    }

    public Shader shader_ = null;
    Shader FXAAShader { get { return shader_ ?? (shader_ = Shader.Find("Aktsk/FXAA")); } }

    private void Reset()
    {
        Debug.Assert(FXAAShader.isSupported);

    }
    void Start()
    {
        Debug.Assert(FXAAShader.isSupported);

        if (!FXAAShader.isSupported) { enabled = false; }
    }

    void OnEnable()
    {
        if (!FXAAShader.isSupported) { enabled = false; }
    }

    void OnDisable()
    {
        if (material_) { DestroyImmediate(material_); }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        FXAAMaterial.SetFloat(ID_SHADERPARAM_EDGE_THRESHOLD_MIN, edgeThresholdMin);
        FXAAMaterial.SetFloat(ID_SHADERPARAM_EDGE_THRESHOLD, edgeThreshold);
        FXAAMaterial.SetFloat(ID_SHADERPARAM_EDGE_SHARPNESS, edgeSharpness);

        Graphics.Blit(src, dest, FXAAMaterial);
    }
}